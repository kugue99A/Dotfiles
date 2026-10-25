"""Update SketchyBar from one bounded worker instead of per-item shell polls."""

from __future__ import annotations

import argparse
import ctypes
import fcntl
import fnmatch
import json
import logging
import os
from pathlib import Path
import re
import shlex
import signal
import socket
import struct
import subprocess
import threading
import time
from datetime import datetime

import psutil


MAX_FRAME = 16 * 1024 * 1024
THEME_COLORS = {
    "dark": {
        "workspaces": (
            "0xffe27878", "0xffe2a478", "0xffe9b189", "0xffb4be82", "0xff89b8c2",
            "0xff84a0c6", "0xffa093c7", "0xff91acd1", "0xffada0d3",
        ),
        "active": None,
        "highlight": "0xffd2d4de",
    },
    "light": {
        "workspaces": (
            "0xffad6e78", "0xffaa805f", "0xff8e8355", "0xff52735f", "0xff648b8e",
            "0xff637c8d", "0xff856d94", "0xff718ba3", "0xff987fa1",
        ),
        "active": "0xff8d769d",
        "highlight": "0xfffaf8f7",
    },
}


def theme_colors() -> dict:
    state_home = os.environ.get("XDG_STATE_HOME") or str(Path.home() / ".local/state")
    try:
        mode = (Path(state_home) / "dotfiles/theme").read_text().strip()
    except OSError:
        mode = "dark"
    return THEME_COLORS.get(mode, THEME_COLORS["dark"])


class AeroSpace:
    def __init__(self, path: str | None = None):
        self.path = path or f"/tmp/bobko.aerospace-{os.environ['USER']}.sock"
        self.socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def __enter__(self):
        self.socket.settimeout(2)
        try:
            self.socket.connect(self.path)
            self.socket.sendall(struct.pack("<I", 1))
            if struct.unpack("<I", self.read_exact(4))[0] != 1:
                raise ValueError("unsupported AeroSpace socket protocol")
        except Exception:
            self.socket.close()
            raise
        return self

    def __exit__(self, *_):
        self.socket.close()

    def read_exact(self, count: int) -> bytes:
        data = bytearray()
        while len(data) < count:
            chunk = self.socket.recv(count - len(data))
            if not chunk:
                raise ConnectionError("AeroSpace closed the connection")
            data.extend(chunk)
        return bytes(data)

    def send(self, args: list[str]):
        data = json.dumps({"args": args, "stdin": "", "windowId": None,
                           "workspace": None}).encode()
        self.socket.sendall(struct.pack("<I", len(data)) + data)

    def receive(self):
        size = struct.unpack("<I", self.read_exact(4))[0]
        if not 0 < size <= MAX_FRAME:
            raise ValueError("invalid AeroSpace frame size")
        return json.loads(self.read_exact(size))

    def run(self, args: list[str]) -> str:
        self.send(args)
        answer = self.receive()
        if answer.get("exitCode") != 0:
            raise RuntimeError("AeroSpace command failed: " + args[0])
        return answer["stdout"]


class IconMap:
    def __init__(self, path: Path):
        self.patterns = []
        source = path.read_text()
        for match in re.finditer(r'(?m)^\s*(.+)\)\s*\n\s*icon_result="([^"\n]+)"', source):
            lexer = shlex.shlex(match[1], posix=True, punctuation_chars="|")
            lexer.whitespace_split = True
            self.patterns.extend((pattern, match[2]) for pattern in lexer if pattern != "|")
        if not self.patterns:
            raise ValueError("app icon map contains no patterns")

    def get(self, name: str) -> str:
        return next((icon for pattern, icon in self.patterns
                     if fnmatch.fnmatchcase(name, pattern)), ":default:")


def workspace_commands(workspaces: str, windows: str, icons: IconMap) -> list[str]:
    palette = theme_colors()
    colors = palette["workspaces"]
    apps: dict[str, list[str]] = {}
    for line in windows.splitlines():
        workspace, separator, app = line.partition("\x1f")
        if separator:
            apps.setdefault(workspace, []).append(icons.get(app))
    commands = []
    for line in workspaces.splitlines():
        fields = line.split("\x1f")
        if len(fields) != 3 or fields[0] not in {str(i) for i in range(1, 10)}:
            continue
        workspace, focused, display = fields
        if not display.isdigit() or int(display) < 1:
            continue
        color = colors[int(workspace) - 1]
        selected = focused == "true"
        background = (palette["active"] or color) if selected else color
        foreground = palette["highlight"] if selected else color
        commands += ["--set", "space." + workspace, "display=" + display,
                     "background.drawing=" + ("on" if selected else "off"),
                     "background.color=" + background, "background.corner_radius=6",
                     "background.height=26", "icon.color=" + foreground,
                     "label.color=" + foreground]
        strip = " ".join(apps.get(workspace, []))
        commands += ["label=" + strip, "label.drawing=" + ("on" if strip else "off")]
    return commands


class Audio:
    class Address(ctypes.Structure):
        _fields_ = [("selector", ctypes.c_uint32), ("scope", ctypes.c_uint32),
                    ("element", ctypes.c_uint32)]

    def __init__(self):
        self.api = ctypes.CDLL("/System/Library/Frameworks/CoreAudio.framework/CoreAudio")
        self.api.AudioObjectGetPropertyData.argtypes = [
            ctypes.c_uint32, ctypes.POINTER(self.Address), ctypes.c_uint32,
            ctypes.c_void_p, ctypes.POINTER(ctypes.c_uint32), ctypes.c_void_p,
        ]
        self.api.AudioObjectGetPropertyData.restype = ctypes.c_int32

    def get(self, device, selector, scope, value_type, element=0):
        address = self.Address(int.from_bytes(selector.encode(), "big"),
                               int.from_bytes(scope.encode(), "big"), element)
        value = value_type()
        size = ctypes.c_uint32(ctypes.sizeof(value))
        result = self.api.AudioObjectGetPropertyData(
            device, ctypes.byref(address), 0, None, ctypes.byref(size), ctypes.byref(value))
        return value.value if result == 0 else None

    def volume(self):
        device = self.get(1, "dOut", "glob", ctypes.c_uint32)
        if not device:
            return None
        volume = self.get(device, "vmvc", "outp", ctypes.c_float)
        if volume is None:
            volume = self.get(device, "volm", "outp", ctypes.c_float)
        if volume is None:
            volume = self.get(device, "volm", "outp", ctypes.c_float, element=1)
        if volume is None:
            return None
        muted = self.get(device, "mute", "outp", ctypes.c_uint32)
        return max(0, min(100, round(volume * 100))), bool(muted)


def metric_commands(audio: Audio) -> list[str]:
    now = datetime.now()
    cpu = psutil.cpu_percent()
    memory = psutil.virtual_memory().percent
    commands = ["--set", "cal.time", "label=" + now.strftime("%H:%M"),
                "--set", "cal.date", "label=" + now.strftime("%m/%d %a"),
                "--set", "cpu", f"label={cpu:.0f}%", "--push", "cpu", f"{cpu / 100:.2f}",
                "--set", "mem", f"label={memory:.0f}%"]
    battery = psutil.sensors_battery()
    if battery is None:
        commands += ["--set", "battery", "drawing=off"]
    else:
        percent = round(battery.percent)
        icon = "󰂄" if battery.power_plugged else next(
            icon for limit, icon in [(10, "󰁺"), (25, "󰁻"), (50, "󰁾"), (75, "󰂁"), (100, "󰁹")]
            if percent <= limit)
        commands += ["--set", "battery", "drawing=on", "icon=" + icon, f"label={percent}%"]
    interfaces = psutil.net_if_addrs()
    stats = psutil.net_if_stats()
    address = None
    interface = None
    for name in sorted(interfaces, key=lambda name: name != "en0"):
        if name not in stats or not stats[name].isup or name.startswith("lo"):
            continue
        address = next((a.address for a in interfaces[name]
                        if a.family == socket.AF_INET and not a.address.startswith("127.")), None)
        if address:
            interface = name
            break
    commands += ["--set", "network", "icon=" + ("󰖩" if interface == "en0" else "󰈀" if address else "󰖪"),
                 "label=" + (address or "未接続")]
    volume = audio.volume()
    if volume is not None:
        percent, muted = volume
        icon = "󰖁" if muted else "󰕿" if percent <= 30 else "󰖀" if percent <= 60 else "󰕾"
        commands += ["--set", "volume", "icon=" + icon, f"label={percent}%"]
    return commands


def send_bar(binary: str, args: list[str], timeout: float = 3):
    process = subprocess.Popen([binary, *args], stdin=subprocess.DEVNULL,
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                               start_new_session=True)
    try:
        status = process.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()
        raise TimeoutError("SketchyBar update exceeded 3 seconds")
    if status:
        raise RuntimeError(f"SketchyBar update exited {status}")


def subscribe(changed: threading.Event, stop: threading.Event):
    while not stop.is_set():
        try:
            with AeroSpace() as aerospace:
                aerospace.send(["subscribe", "focus-changed", "focused-workspace-changed",
                                "focused-monitor-changed", "window-detected"])
                # An idle stream is normal; do not discard a partially read frame.
                aerospace.socket.settimeout(None)
                while not stop.is_set():
                    aerospace.receive()
                    changed.set()
        except (OSError, ValueError, ConnectionError):
            stop.wait(2)


def collect(icons: IconMap, audio: Audio) -> list[str]:
    commands = metric_commands(audio)
    with AeroSpace() as aerospace:
        workspaces = aerospace.run([
            "list-workspaces", "--all", "--format",
            "%{workspace}\x1f%{workspace-is-focused}\x1f%{monitor-appkit-nsscreen-screens-id}"])
        windows = aerospace.run(["list-windows", "--all", "--format", "%{workspace}\x1f%{app-name}"])
    return workspace_commands(workspaces, windows, icons) + commands


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    options = parser.parse_args()
    icons = IconMap(Path.home() / ".config/sketchybar/helpers/icon_map.sh")
    audio = Audio()
    if options.dry_run:
        commands = collect(icons, audio)
        print(json.dumps({"workspace_updates": sum(a.startswith("space.") for a in commands),
                          "argument_count": len(commands), "volume_available": audio.volume() is not None}))
        return
    state = Path.home() / ".local/state/sketchybar"
    state.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (state / "status.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        stop = threading.Event()
        changed = threading.Event()
        for sig in (signal.SIGINT, signal.SIGTERM):
            signal.signal(sig, lambda *_: (stop.set(), changed.set()))
        threading.Thread(target=subscribe, args=(changed, stop), daemon=True).start()
        last_error = 0.0
        while not stop.is_set():
            started = time.monotonic()
            changed.clear()
            try:
                send_bar(os.environ["SKETCHYBAR_BINARY"], collect(icons, audio))
            except (OSError, ValueError, ConnectionError, RuntimeError, TimeoutError) as error:
                if time.monotonic() - last_error > 60:
                    logging.warning("%s", error)
                    last_error = time.monotonic()
            # Events coalesce; metrics are also refreshed at least every five seconds.
            stop.wait(max(0, 0.5 - (time.monotonic() - started)))
            changed.wait(timeout=max(0, 5 - (time.monotonic() - started)))


if __name__ == "__main__":
    main()

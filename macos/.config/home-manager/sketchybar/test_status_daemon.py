import json
from pathlib import Path
import socket
import struct
import sys
import tempfile
import threading
import time
import unittest

from status_daemon import AeroSpace, IconMap, send_bar, workspace_commands


class SocketProtocolTests(unittest.TestCase):
    def test_handshake_and_fragmented_unicode_response(self):
        with tempfile.TemporaryDirectory(prefix="bar-protocol-") as directory:
            path = str(Path(directory) / "socket")
            server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            server.bind(path)
            server.listen(1)
            received = []
            errors = []

            def serve():
                try:
                    with server.accept()[0] as peer:
                        def read(count):
                            data = b""
                            while len(data) < count:
                                data += peer.recv(count - len(data))
                            return data
                        self.assertEqual(read(4), struct.pack("<I", 1))
                        peer.sendall(struct.pack("<I", 1))
                        size = struct.unpack("<I", read(4))[0]
                        received.append(json.loads(read(size)))
                        answer = json.dumps({"exitCode": 0, "stdout": "仕事", "stderr": ""},
                                            ensure_ascii=False).encode()
                        frame = struct.pack("<I", len(answer)) + answer
                        for byte in frame:
                            peer.sendall(bytes([byte]))
                except BaseException as error:
                    errors.append(error)
                finally:
                    server.close()

            thread = threading.Thread(target=serve, daemon=True)
            thread.start()
            with AeroSpace(path) as client:
                self.assertEqual(client.run(["list-workspaces", "--focused"]), "仕事")
            thread.join(timeout=3)
            self.assertFalse(thread.is_alive())
            if errors:
                raise errors[0]
            self.assertEqual(received[0]["args"], ["list-workspaces", "--focused"])

    def test_rejects_oversized_frames_before_allocating(self):
        client = AeroSpace("/unused")
        client.socket.close()
        client.socket, peer = socket.socketpair()
        try:
            peer.sendall(struct.pack("<I", 16 * 1024 * 1024 + 1))
            with self.assertRaises(ValueError):
                client.receive()
        finally:
            client.socket.close()
            peer.close()


class WorkspaceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        path = Path(self.directory.name) / "icons.sh"
        path.write_text('''case "$1" in
"Code" | "Visual Studio Code")
  icon_result=":code:"
  ;;
"Adobe Photoshop"*)
  icon_result=":photoshop:"
  ;;
*)
  icon_result=":default:"
  ;;
esac
''')
        self.icons = IconMap(path)

    def tearDown(self):
        self.directory.cleanup()

    def test_icon_aliases_and_globs(self):
        self.assertEqual(self.icons.get("Visual Studio Code"), ":code:")
        self.assertEqual(self.icons.get("Adobe Photoshop 2026"), ":photoshop:")
        self.assertEqual(self.icons.get("Other App"), ":default:")

    def test_uses_appkit_display_and_clears_empty_workspaces(self):
        result = workspace_commands("1\x1ftrue\x1f2\n2\x1ffalse\x1f1",
                                    "1\x1fCode\n1\x1fOther App", self.icons)
        first = result[:result.index("--set", 1)]
        self.assertIn("space.1", first)
        self.assertIn("display=2", first)
        self.assertIn("background.drawing=on", first)
        self.assertIn("label=:code: :default:", first)
        self.assertIn("label.drawing=off", result)
        self.assertIn("label=", result)


class ProcessTests(unittest.TestCase):
    def test_timed_out_update_is_killed_and_reaped(self):
        started = time.monotonic()
        with self.assertRaises(TimeoutError):
            send_bar(sys.executable, ["-c", "import time; time.sleep(20)"], timeout=0.05)
        self.assertLess(time.monotonic() - started, 3)


if __name__ == "__main__":
    unittest.main()

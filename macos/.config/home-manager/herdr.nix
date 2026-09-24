{ config, lib, pkgs, ... }:

let
  toastSoundPath = "${config.home.homeDirectory}/.config/herdr/sounds/tirori-2loops.mp3";
in
{
  home.file.".config/herdr/sounds/tirori-2loops.mp3".source = ./sounds/tirori-2loops.mp3;

  home.file.".config/herdr/config.toml".text = ''
    # Herdr keybindings aligned with the local tmux/Zellij-style layout.
    onboarding = false

    [terminal]
    default_shell = "${pkgs.fish}/bin/fish"
    shell_mode = "auto"
    new_cwd = "follow"

    [ui]
    sidebar_min_width = 36
    sidebar_max_width = 36

    [ui.sidebar.agents]
    row_gap = 0
    rows = [
      ["state_icon", "$title"],
      ["$provider", "$limit"],
      ["$context"],
    ]

    [ui.toast]
    delivery = "system"
    delay_seconds = 1

    [ui.sound]
    enabled = true
    path = "${toastSoundPath}"

    [keys]
    # Herdr supports one real prefix key. Alt/Option bindings below mirror the
    # tmux-style prefix keys as direct shortcuts where the terminal sends them.
    prefix = "ctrl+q"

    # Keep Herdr commands available while freeing tmux-compatible keys.
    settings = ["prefix+comma", "alt+comma"]
    reload_config = "prefix+alt+r"

    help = ["prefix+?", "alt+?"]
    detach = ["prefix+d", "alt+d"]
    open_notification_target = ["prefix+o", "alt+o"]

    workspace_picker = ["prefix+w", "alt+w"]
    goto = ["prefix+g", "alt+g"]
    new_workspace = ["prefix+shift+n", "alt+shift+n"]
    new_worktree = ["prefix+shift+g", "alt+shift+g"]
    open_worktree = ["prefix+shift+o", "alt+shift+o"]
    rename_workspace = ["prefix+shift+w", "alt+shift+w"]
    close_workspace = ["prefix+shift+d", "alt+shift+d"]

    new_tab = ["prefix+c", "alt+c"]
    rename_tab = ["prefix+r", "alt+r"]
    previous_tab = ["prefix+p", "alt+p"]
    next_tab = ["prefix+n", "alt+n"]
    switch_tab = ["prefix+1..9", "alt+1..9"]
    close_tab = ["prefix+shift+x", "alt+shift+x"]
    rename_pane = ["prefix+shift+p", "alt+shift+p"]
    edit_scrollback = ["prefix+e", "alt+e"]

    focus_pane_left = ["prefix+h", "alt+h"]
    focus_pane_down = ["prefix+j", "alt+j"]
    focus_pane_up = ["prefix+k", "alt+k"]
    focus_pane_right = ["prefix+l", "alt+l"]
    swap_pane_left = ""
    swap_pane_down = ""
    swap_pane_up = ""
    swap_pane_right = ""

    split_vertical = ["prefix+v", "alt+v"]
    split_horizontal = ["prefix+s", "alt+s"]
    close_pane = ["prefix+x", "alt+x"]
    copy_mode = ["prefix+[", "alt+["]
    zoom = ["prefix+z", "alt+z"]

    # Keep Herdr resize mode available; direct H/J/K/L resize is below.
    resize_mode = ["prefix+shift+r", "alt+shift+r"]
    toggle_sidebar = ["prefix+b", "alt+t"]

    navigate_pane_left = "h"
    navigate_pane_down = "j"
    navigate_pane_up = "k"
    navigate_pane_right = "l"

    # Direct resize shortcuts matching tmux Prefix+H/J/K/L and Alt+H/J/K/L.
    [[keys.command]]
    key = ["prefix+shift+h", "alt+shift+h"]
    type = "shell"
    command = "herdr pane resize --direction left --amount 5 --current"

    [[keys.command]]
    key = ["prefix+shift+j", "alt+shift+j"]
    type = "shell"
    command = "herdr pane resize --direction down --amount 5 --current"

    [[keys.command]]
    key = ["prefix+shift+k", "alt+shift+k"]
    type = "shell"
    command = "herdr pane resize --direction up --amount 5 --current"

    [[keys.command]]
    key = ["prefix+shift+l", "alt+shift+l"]
    type = "shell"
    command = "herdr pane resize --direction right --amount 5 --current"
  '';

  # Keep the Agent Usage plugin present alongside the Home Manager config.
  # The plugin owns its own versioned binary and startup hook; only install it
  # when it is not already registered with Herdr.
  home.activation.herdrAgentUsagePlugin = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    herdr() {
      ${pkgs.mise}/bin/mise exec -- herdr "$@"
    }

    if herdr --version >/dev/null 2>&1; then
      if ! herdr plugin list --json | ${pkgs.jq}/bin/jq -e '.result.plugins[]? | select(.plugin_id == "usagebar")' >/dev/null 2>&1; then
        herdr plugin install senna-lang/herdr-agent-usage --yes
      fi
    else
      echo "warning: Herdr is not installed; run 'mise install' to enable Agent Usage" >&2
    fi
  '';
}

{ config, lib, pkgs, ... }:

let
  toastSoundPath = "${config.home.homeDirectory}/.config/herdr/sounds/tirori-2loops.mp3";
in
{
  home.file.".config/herdr/sounds/tirori-2loops.mp3".source = ./sounds/tirori-2loops.mp3;

  # Claude Code exposes current subscription windows in its statusLine
  # payload. Feed it into Agent Usage's Claude cache.
  home.file.".local/bin/herdr-claude-statusline" = {
    executable = true;
    text = ''
      #!/bin/sh
      set -eu

      statusline_tmp=$(mktemp "''${TMPDIR:-/tmp}/herdr-claude-statusline.XXXXXX") || exit 0
      trap 'rm -f "$statusline_tmp"' EXIT
      cat >"$statusline_tmp"

      plugin_root=$(${pkgs.mise}/bin/mise exec -- herdr plugin list --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.result.plugins[]? | select(.plugin_id == "usagebar") | .plugin_root' | head -n 1)
      if [ -n "$plugin_root" ] && [ -x "$plugin_root/bin/run-usagebar.sh" ]; then
        "$plugin_root/bin/run-usagebar.sh" statusline <"$statusline_tmp" >/dev/null 2>&1 || true
      fi
    '';
  };

  home.file.".config/herdr/config.toml".text = ''
    # Herdr keybindings aligned with the local tmux/Zellij-style layout.
    onboarding = false

    [theme]
    # Follow WezTerm's active ANSI palette (Tokyo Night or Ashes Light).
    name = "terminal"

    # Ashes-inspired light palette. Keep active tabs and active sidebar rows
    # on the same lavender/dark-slate combination.
    [theme.custom]
    panel_bg = "#F4F2F4"
    text = "#273139"
    subtext0 = "#414D55"
    overlay0 = "#536169"
    overlay1 = "#414D55"
    accent = "#D9C9DF"
    active_row_bg = "#D9C9DF"
    selection_bg = "#CDB8D5"
    mauve = "#70586F"
    green = "#456B57"
    yellow = "#776A41"
    red = "#965C58"
    blue = "#586F91"
    teal = "#4D7777"
    peach = "#91664F"

    [terminal]
    default_shell = "${pkgs.fish}/bin/fish"
    shell_mode = "auto"
    new_cwd = "follow"

    [ui]
    sidebar_min_width = 36
    sidebar_max_width = 36
    # Keep navigation/border accents distinct from the shared active fill.
    accent = "#735C84"

    [ui.sidebar.spaces]
    rows = [
      ["state_icon", { token = "workspace", fg = "#273139", bold = true, dim = false }],
      [{ token = "branch", fg = "#46535B", dim = false }, "git_status"],
    ]

    [ui.sidebar.agents]
    row_gap = 0
    rows = [
      ["state_icon", { token = "$title", fg = "#273139", bold = true, dim = false }],
      [
        { token = "$provider", fg = "#46535B", dim = false },
        { token = "$limit", fg = "#46535B", dim = false },
      ],
      [{ token = "$context", fg = "#46535B", dim = false }],
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

  # The upstream plugin's rollout reader can only see old Codex snapshots.
  # Apply the live app-server reader and rebuild the plugin after installation
  # so the fix survives plugin upgrades and Home Manager re-activation.
  home.activation.herdrAgentUsageCodexFix = lib.hm.dag.entryAfter [ "herdrAgentUsagePlugin" ] ''
    herdr() {
      ${pkgs.mise}/bin/mise exec -- herdr "$@"
    }

    if herdr --version >/dev/null 2>&1; then
      plugin_root=$(herdr plugin list --json | ${pkgs.jq}/bin/jq -r '.result.plugins[]? | select(.plugin_id == "usagebar") | .plugin_root' | head -n 1)
      if [ -n "$plugin_root" ] && [ -f "$plugin_root/go.mod" ]; then
        if [ ! -f "$plugin_root/internal/limits/codexappserver.go" ]; then
          ${pkgs.git}/bin/git -C "$plugin_root" apply ${./herdr-agent-usage-codex.patch}
        fi
        if [ -f "$plugin_root/internal/limits/codexappserver.go" ]; then
          if ! grep -q "live Claude statusLine unavailable" "$plugin_root/internal/limits/claudecache.go"; then
            ${pkgs.git}/bin/git -C "$plugin_root" apply ${./herdr-agent-usage-claude.patch}
          fi
          (cd "$plugin_root" && ${pkgs.mise}/bin/mise exec -- go build -o bin/usagebar ./cmd/usagebar)
          herdr server reload-config >/dev/null 2>&1 || true
          "$plugin_root/bin/usagebar" startup >/dev/null 2>&1 || true
        fi
      fi
    fi
  '';

  home.activation.herdrClaudeStatusline = lib.hm.dag.entryAfter [ "herdrAgentUsageCodexFix" ] ''
    claude_settings="$HOME/.claude/settings.json"
    claude_wrapper="$HOME/.local/bin/herdr-claude-statusline"
    if [ -f "$claude_settings" ] && [ -x "$claude_wrapper" ]; then
      current_statusline=$(${pkgs.jq}/bin/jq -r '.statusLine.command // empty' "$claude_settings" 2>/dev/null || true)
      if [ -z "$current_statusline" ]; then
        claude_tmp=$(mktemp "$HOME/.claude/settings.json.herdr.XXXXXX")
        if ${pkgs.jq}/bin/jq --arg command "$claude_wrapper" '.statusLine = {type: "command", command: $command}' "$claude_settings" >"$claude_tmp"; then
          chmod --reference="$claude_settings" "$claude_tmp" 2>/dev/null || true
          mv "$claude_tmp" "$claude_settings"
        else
          rm -f "$claude_tmp"
        fi
      fi
    fi
  '';
}

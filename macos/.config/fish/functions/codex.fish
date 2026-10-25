# Codex shades its composer using the probed terminal background. Restrict its
# color depth to ANSI-256 so WezTerm can map that fill to the soft Ashes panel
# color while keeping the terminal's default/window background unchanged.
function codex
    set -lx FORCE_COLOR 2
    command codex $argv
end

local wezterm = require("wezterm")

local config = wezterm.config_builder()
config:set_strict_mode(true)

config.font = wezterm.font("SauceCodePro Nerd Font Mono")
config.font_size = 13

-- 左右どちらの Option キーも Alt/Meta として送る
-- (デフォルトは右 Option が合成入力になり Herdr の alt+... が効かないため)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Default shell - use fish (Nix-managed)
config.default_prog = { wezterm.home_dir .. "/.nix-profile/bin/fish" }

-- Image display support (Kitty, iTerm2, Sixel protocols)
config.enable_kitty_graphics = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.01
config.hide_tab_bar_if_only_one_tab = true

-- Shared with the `theme` Fish command and Neovim.
local xdg_state_home = os.getenv("XDG_STATE_HOME")
local state_dir = xdg_state_home and xdg_state_home ~= "" and xdg_state_home or (wezterm.home_dir .. "/.local/state")
local theme_file = state_dir .. "/dotfiles/theme"
wezterm.add_to_config_reload_watch_list(theme_file)
local theme = "dark"
local file = io.open(theme_file, "r")
if file then
	theme = file:read("*l") or theme
	file:close()
end

local schemes = wezterm.color.get_builtin_schemes()
local ashes_light_scheme = {}
for key, value in pairs(schemes["Ashes (light) (terminal.sexy)"]) do
	ashes_light_scheme[key] = value
end
-- Codex shades its composer with an ANSI-256 color derived from the terminal
-- background. Keep that surface close to white, and soften Codex's quantized
-- blue/cyan/green accents to match Ashes Light. The terminal background below
-- stays unchanged.
local ashes_indexed = {}
for index, value in pairs(ashes_light_scheme.indexed or {}) do
	ashes_indexed[index] = value
end
ashes_indexed[46] = "#7FA18C"
ashes_indexed[75] = "#637C8D"
ashes_indexed[81] = "#7B9DA4"
ashes_indexed[237] = "#F7F6F6"
-- Codex's submitted-prompt surface is blended from the reported dark
-- terminal background and quantized to xterm gray 238 in ANSI-256 mode.
ashes_indexed[238] = "#E8E4EA"
ashes_light_scheme.indexed = ashes_indexed
-- Ashes Light's pastel ANSI greens are too low-contrast over a bright desktop
-- through the translucent window. Keep the Ashes hue, but darken green text.
local ashes_ansi = {}
for index, value in ipairs(ashes_light_scheme.ansi or {}) do
	ashes_ansi[index] = value
end
local ashes_brights = {}
for index, value in ipairs(ashes_light_scheme.brights or {}) do
	ashes_brights[index] = value
end
ashes_ansi[3] = "#52735F"
ashes_brights[3] = "#6C8D77"
ashes_light_scheme.ansi = ashes_ansi
ashes_light_scheme.brights = ashes_brights
-- Use a muted Ashes blue-gray for normal and IME-composition cursors.
ashes_light_scheme.cursor_bg = "#637C8D"
ashes_light_scheme.cursor_border = "#637C8D"
ashes_light_scheme.cursor_fg = "#F7F6F6"
ashes_light_scheme.compose_cursor = "#637C8D"
-- Keep the existing Tokyo Night window background while using Ashes Light's
-- foreground and ANSI palette.
ashes_light_scheme.background = schemes["Tokyo Night"].background
config.color_schemes = { ["Ashes Light Glass"] = ashes_light_scheme }

if theme == "light" then
	config.color_scheme = "Ashes Light Glass"
	config.macos_window_background_blur = 20
else
	config.color_scheme = "Tokyo Night"
	config.macos_window_background_blur = 0
end

-- Bell notification (AeroSpaceでフォーカス外でも通知が届くように)
config.audible_bell = "SystemBeep"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}
-- ベル時にmacOS通知センターにも通知を送る（バックグラウンドで動作）
config.notification_handling = "AlwaysShow"
config.keys = {
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\n"),
	},
}

return config

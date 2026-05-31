local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("SauceCodePro Nerd Font Mono")
config.font_size = 13

-- Default shell - use fish (Nix-managed)
config.default_prog = { wezterm.home_dir .. "/.nix-profile/bin/fish" }

-- Image display support (Kitty, iTerm2, Sixel protocols)
config.enable_kitty_graphics = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.7
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 20
config.color_scheme = "Gruvbox Dark(Gogh)"

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

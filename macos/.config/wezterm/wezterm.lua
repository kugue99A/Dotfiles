local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("SauceCodePro Nerd Font Mono")
config.font_size = 13

-- Default shell - use fish (Nix-managed)
config.default_prog = { "/Users/s26988/.nix-profile/bin/fish" }

-- Image display support (Kitty, iTerm2, Sixel protocols)
config.enable_kitty_graphics = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.7
config.hide_tab_bar_if_only_one_tab = true
config.macos_window_background_blur = 20
config.color_scheme = "Gruvbox Dark(Gogh)"
config.keys = {
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\n"),
	},
}

return config

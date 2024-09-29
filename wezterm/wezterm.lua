local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.font_size = 13

config.font = wezterm.font("SauceCodePro Nerd Font Mono")

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = "Gruvbox Dark(Gogh)"

return config

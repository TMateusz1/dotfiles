-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- background
config.window_background_opacity = 0.97
config.color_scheme = "Tokyo Night"

-- font config
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 16
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- nice symbols
-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 99999

return config

-- Pull in the wezterm API
local wezterm = require 'wezterm'

local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
  window:set_title 'WSL'
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

config.audible_bell = "Disabled"

config.default_domain = 'WSL:Ubuntu'

-- For example, changing the color scheme:
config.color_scheme = 'Tokyo Night'

config.font = wezterm.font 'CaskaydiaMono Nerd Font'
config.font_size = 10

config.term = "xterm-256color"
config.enable_tab_bar = false

config.window_background_image = 'C:\\Users\\hardi\\Pictures\\Saved Pictures\\minimalist-planet.jpg'

config.window_background_image_hsb = {
	brightness = .01
}

config.window_background_opacity = 1.0

config.window_decorations = "RESIZE | TITLE"

-- and finally, return the configuration to wezterm
return config

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
config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false

config.audible_bell = "Disabled"
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'CaskaydiaMono Nerd Font'
config.font_size = 10
config.term = "xterm-256color"
config.enable_tab_bar = false

config.window_background_image = 'C:\\Users\\hardi\\Documents\\TermBG\\6.jpg'
config.window_background_image_hsb = {
	brightness = .01
}

--config.window_decorations = "RESIZE | TITLE"
config.window_decorations = "RESIZE"

-- and finally, return the configuration to wezterm
return config

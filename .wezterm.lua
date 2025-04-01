local wezterm = require 'wezterm'

local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
end)

wezterm.on('format-window-title', function ()
  return "Wezterm"
end)

local config = wezterm.config_builder()
config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false

config.audible_bell = "Disabled"
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'CaskaydiaMono Nerd Font Mono'
config.font_size = 11
config.term = "xterm-256color"
config.enable_tab_bar = false

config.window_background_image = 'C:\\Documents\\TermBG\\07.jpg'
config.window_background_image_hsb = {
  brightness = .008
}

--config.window_decorations = "RESIZE"

config.keys = {
  {
    key = 't',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.DisableDefaultAssignment,
  }
}

return config

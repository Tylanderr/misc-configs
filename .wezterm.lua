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

config.window_decorations = "RESIZE"
config.window_background_image_hsb = {
	brightness = .02
}
local background = 'C:\\Documents\\TermBG\\11.jpg'

wezterm.on('toggle-background', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.window_background_image then
        overrides.window_background_image = background
    else
        overrides.window_background_image = nil
    end
    window:set_config_overrides(overrides)
end)

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
  },
  {
    key = 'B',
    mods = 'CTRL',
    action = wezterm.action.EmitEvent 'toggle-background',
  },
}

return config

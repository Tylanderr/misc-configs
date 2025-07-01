local wezterm = require 'wezterm'
local mux = wezterm.mux

local config = wezterm.config_builder()
config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false

config.audible_bell = "Disabled"
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'CaskaydiaMono Nerd Font Mono'
config.font_size = 10
config.term = "xterm-256color"
config.enable_tab_bar = false

local opacity = 1
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = opacity

wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.95
  else
    overrides.window_background_opacity = nil
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
    action = wezterm.action.EmitEvent 'toggle-opacity',
  },
}

return config

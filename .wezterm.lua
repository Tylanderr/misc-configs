local wezterm = require 'wezterm'
local mux = wezterm.mux

-- wezterm.on("gui-startup", function()
--   local tab, pane, window = mux.spawn_window{}
--   window:gui_window():maximize()
-- end)

local config = wezterm.config_builder()
config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false

config.audible_bell = "Disabled"
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'CaskaydiaMono Nerd Font Mono'
config.font_size = 10
config.term = "xterm-256color"
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

local opacity = 1
local background = 'C:\\Documents\\TermBG\\02.jpg'
config.window_background_image_hsb = { brightness = .0025 }
config.window_background_opacity = opacity
-- config.window_background_image = background

wezterm.on('toggle-background', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current = overrides.window_background_image
  if current == nil then
    overrides.window_background_image = ''
  elseif current == '' then
    overrides.window_background_image = background_image
  else
    overrides.window_background_image = ''
  end
  window:set_config_overrides(overrides)
end)

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
    key = '.',
    mods = 'CTRL',
    action = wezterm.action.EmitEvent 'toggle-opacity',
  }
}

return config

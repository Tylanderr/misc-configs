local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local normal_font_size = 11
local compact_font_size = 9.5
local opaque_bg = 1
local translucent_bg = 0.95

config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false
config.enable_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.term = 'xterm-256color'
config.audible_bell = 'Disabled'
config.color_scheme = 'Tokyo Night'
config.font_size = normal_font_size
config.font = wezterm.font 'CaskaydiaMono Nerd Font Mono'
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'
config.window_background_opacity = translucent_bg
-- config.window_background_image = 'C:\\Documents\\WezTerm\\TermBG\\03.jpg'

wezterm.on('toggle-background', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if config.window_background_image then
    local current_image = overrides.window_background_image
    if current_image == nil then
      current_image = config.window_background_image
    end
    if current_image == '' then
      overrides.window_background_image = config.window_background_image
      overrides.window_background_opacity = nil
    else
      overrides.window_background_image = ''
      overrides.window_background_opacity = translucent_bg
    end
  else
    local current_opacity = overrides.window_background_opacity
    if current_opacity == nil then
      current_opacity = config.window_background_opacity
    end
    if current_opacity < opaque_bg then
      overrides.window_background_opacity = opaque_bg
    else
      overrides.window_background_opacity = translucent_bg
    end
  end
  window:set_config_overrides(overrides)
end)

wezterm.on('font-size-switch', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local current_font_size = overrides.font_size or config.font_size
  if current_font_size == normal_font_size then
    overrides.font_size = compact_font_size
  else
    overrides.font_size = normal_font_size
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
    key = 'Enter',
    mods = 'CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = '.',
    mods = 'ALT',
    action = wezterm.action.EmitEvent 'toggle-background',
  },
  {
    key = ',',
    mods = 'ALT',
    action = wezterm.action.EmitEvent 'font-size-switch',
  },
}
return config

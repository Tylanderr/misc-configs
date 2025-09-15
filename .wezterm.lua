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
config.adjust_window_size_when_changing_font_size = false
config.term = "xterm-256color"
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

local current_font_size = 9.5
config.font_size = current_font_size

config.window_background_opacity = 1
--local background = 'C:\\Documents\\WezTerm\\TermBG\\05.jpg'
config.window_background_image = background

wezterm.on('toggle-background', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if config.window_background_image then
      local current = overrides.window_background_image
      if current == nil then
        overrides.window_background_image = ''
        overrides.window_background_opacity = 0.95
      elseif current == '' then
        overrides.window_background_image = background_image
        overrides.window_background_opacity = nil
      else
        overrides.window_background_image = ''
        overrides.window_background_opacity = nil
      end
    else
      local current_opacity = overrides.window_background_opacity
      if current_opacity == 1 or current_opacity == nil then
        overrides.window_background_opacity = 0.95
      else
        overrides.window_background_opacity = 1
      end
    end  
    window:set_config_overrides(overrides)
end)

wezterm.on('font-size-switch', function(window, pane)
  if current_font_size == 11 then
    current_font_size = 9.5
  else
    current_font_size = 11
  end

  window:set_config_overrides({
    font_size = current_font_size
  })
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
    action = wezterm.action.EmitEvent 'toggle-background',
  },
  {
    key = ',',
    mods = 'CTRL',
    action = wezterm.action.EmitEvent 'font-size-switch'
  }
}

return config

local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local opacity_state_file = wezterm.config_dir .. '/window-opacity'

local function load_saved_opacity()
  local file = io.open(opacity_state_file, 'r')
  if not file then
    return 1
  end

  local value = file:read('*a')
  file:close()

  local opacity = tonumber(value)
  if opacity == nil or opacity < 0 or opacity > 1 then
    return 1
  end

  return opacity
end

local function save_opacity(opacity)
  local file = io.open(opacity_state_file, 'w')
  if not file then
    wezterm.log_error('Unable to save window opacity to ' .. opacity_state_file)
    return
  end

  file:write(tostring(opacity))
  file:close()
end

config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false
config.enable_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.term = "xterm-256color"
config.audible_bell = "Disabled"
config.color_scheme = 'Tokyo Night'
config.font_size = 11
config.font = wezterm.font 'CaskaydiaMono Nerd Font Mono'
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = load_saved_opacity()
-- config.window_background_image = 'C:\\Documents\\WezTerm\\TermBG\\03.jpg'

wezterm.on('toggle-background', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if config.window_background_image then
      local current = overrides.window_background_image
      if current == nil then
        overrides.window_background_image = ''
        overrides.window_background_opacity = 0.95
        save_opacity(overrides.window_background_opacity)
      elseif current == '' then
        overrides.window_background_image = background_image
        overrides.window_background_opacity = nil
        save_opacity(config.window_background_opacity)
      else
        overrides.window_background_image = ''
        overrides.window_background_opacity = nil
        save_opacity(config.window_background_opacity)
      end
    else
      local current_opacity = overrides.window_background_opacity
      if current_opacity == 1 or current_opacity == nil then
        overrides.window_background_opacity = 0.95
      else
        overrides.window_background_opacity = 1
      end

      save_opacity(overrides.window_background_opacity)
    end  
    window:set_config_overrides(overrides)
end)

wezterm.on('font-size-switch', function(window, pane)
  local overrides = window:get_config_overrides() or {}

  if config.font_size == 11 then
    config.font_size = 9.5
  else
    config.font_size = 11
  end

  overrides.font_size = config.font_size
  overrides.window_background_opacity = overrides.window_background_opacity or config.window_background_opacity
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
    action = wezterm.action.EmitEvent 'font-size-switch'
  }
}

return config

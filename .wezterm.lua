local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local normal_font_size = 11
local compact_font_size = 9.5
local solid_bg = 1
local opaque_bg = 0.95

local transparent_flag = true
local bg_image = nil
--local bg_image = 'C:\\Documents\\WezTerm\\TermBG\\02.jpg'

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

-- Always start fully opaque, without a background image.
config.window_background_opacity = solid_bg
config.window_background_image = nil

local function get_background_state(window)
  local state_key = 'startup_background_' .. tostring(window:window_id())
  local state = wezterm.GLOBAL[state_key]
  local dimensions = window:get_dimensions()

  if not state then
    state = {
      initial_width = dimensions.pixel_width,
      initial_height = dimensions.pixel_height,
      last_width = dimensions.pixel_width,
      last_height = dimensions.pixel_height,
    }

    wezterm.GLOBAL[state_key] = state
  end

  return state, state_key, dimensions
end

-- Preserve the first observed dimensions across configuration reloads.
wezterm.on('window-config-reloaded', function(window)
  get_background_state(window)
end)

wezterm.on('window-resized', function(window)
  local state, state_key, dimensions = get_background_state(window)

  -- Ignore events that did not change the window's pixel dimensions.
  if dimensions.pixel_width == state.last_width
    and dimensions.pixel_height == state.last_height then
    return
  end

  state.last_width = dimensions.pixel_width
  state.last_height = dimensions.pixel_height
  wezterm.GLOBAL[state_key] = state

  local is_startup_size =
    dimensions.pixel_width == state.initial_width
    and dimensions.pixel_height == state.initial_height

  local desired_opacity = solid_bg
  local desired_image = nil

  if not is_startup_size then
    if transparent_flag then
      desired_opacity = opaque_bg
    else
      desired_image = bg_image
    end
  end

  local overrides = window:get_config_overrides() or {}
  local current_opacity =
    overrides.window_background_opacity
    or config.window_background_opacity

  if current_opacity == desired_opacity
    and overrides.window_background_image == desired_image then
    return
  end

  overrides.window_background_opacity = desired_opacity
  overrides.window_background_image = desired_image

  window:set_config_overrides(overrides)
end)

wezterm.on('toggle-background', function(window)
  local overrides = window:get_config_overrides() or {}
  local current_opacity =
    overrides.window_background_opacity
    or config.window_background_opacity

  if current_opacity == opaque_bg then
    overrides.window_background_opacity = solid_bg
    overrides.window_background_image = bg_image
  else
    overrides.window_background_opacity = opaque_bg
    overrides.window_background_image = nil
  end

  window:set_config_overrides(overrides)
end)

wezterm.on('font-size-switch', function(window)
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

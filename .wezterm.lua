local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local normal_font_size = 11
local compact_font_size = 9.5
local solid_bg = 1
local opaque_bg = 0.95

local transparent_flag = false

-- ---------------------------------------------------------------------------
-- Background image discovery + persistence
-- ---------------------------------------------------------------------------

local background_dir = wezterm.config_dir .. '/TermBG'
local background_state_file = background_dir .. '/.selected-background'

local function get_file_name(path)
  return path:match '[^/\\]+$'
end

local function get_available_backgrounds()
  local backgrounds = {}

  for _, path in ipairs(wezterm.glob(background_dir .. '/*')) do
    local extension = path:match '%.([^./\\]+)$'

    if extension then
      extension = extension:lower()

      if extension == 'jpg'
        or extension == 'jpeg'
        or extension == 'png'
        or extension == 'webp'
        or extension == 'gif' then
        table.insert(backgrounds, path)
      end
    end
  end

  -- Keep cycling order predictable.
  table.sort(backgrounds, function(left, right)
    return left:lower() < right:lower()
  end)

  return backgrounds
end

local function read_selected_background()
  local file = io.open(background_state_file, 'r')

  if not file then
    return nil
  end

  local selected_file_name = file:read '*l'
  file:close()

  return selected_file_name
end

local function save_selected_background(path)
  local file = io.open(background_state_file, 'w')

  if not file then
    wezterm.log_error(
      'Unable to save the selected background to: '
        .. background_state_file
    )
    return
  end

  file:write(get_file_name(path))
  file:close()
end

local backgrounds = get_available_backgrounds()
local saved_background = read_selected_background()
local background_index = 1

-- Restore the last selected background.
if saved_background then
  for index, path in ipairs(backgrounds) do
    if get_file_name(path) == saved_background then
      background_index = index
      break
    end
  end
end

local bg_image = backgrounds[background_index]

-- ---------------------------------------------------------------------------
-- Color scheme
-- ---------------------------------------------------------------------------

local color_scheme = 'Tokyo Night'
local scheme_bg = wezterm.color.get_builtin_schemes()[color_scheme].background

-- ---------------------------------------------------------------------------
-- General configuration
-- ---------------------------------------------------------------------------

config.default_domain = 'WSL:Ubuntu'
config.check_for_updates = false
config.enable_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.term = 'xterm-256color'
config.audible_bell = 'Disabled'
config.color_scheme = color_scheme
config.font_size = normal_font_size
config.font = wezterm.font 'CaskaydiaMono Nerd Font Mono'
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'

-- ---------------------------------------------------------------------------
-- Background
-- ---------------------------------------------------------------------------

-- Background modes:
--   'hidden'      -> solid scheme color; image loaded but fully covered
--   'image'       -> background image shown
--   'transparent' -> translucent scheme color, image not visible

local function build_background(mode)
  local layers = {}

  if bg_image then
    -- Image layer is always present so it stays loaded/cached.
    table.insert(layers, {
      source = { File = bg_image },
      width = '100%',
      height = '100%',
      opacity = mode == 'transparent' and 0.0 or 1.0,
    })
  end

  if mode == 'hidden' or not bg_image then
    table.insert(layers, {
      source = { Color = scheme_bg },
      width = '100%',
      height = '100%',
      opacity = solid_bg,
    })
  elseif mode == 'transparent' then
    table.insert(layers, {
      source = { Color = scheme_bg },
      width = '100%',
      height = '100%',
      opacity = opaque_bg,
    })
  end

  -- Without an image, 'transparent' still needs the translucent color.
  if not bg_image and mode == 'transparent' then
    layers[#layers].opacity = opaque_bg
  end

  return layers
end

-- Always start fully opaque, with the selected image preloaded underneath
-- a solid layer.
config.background = build_background('hidden')

-- ---------------------------------------------------------------------------
-- Per-window background state
-- ---------------------------------------------------------------------------

local function get_background_state(window)
  local state_key = 'startup_background_' .. tostring(window:window_id())
  local state = wezterm.GLOBAL[state_key]
  local dimensions = window:get_dimensions()

  if not state then
    state = {
      first_open = true,
      initial_width = dimensions.pixel_width,
      initial_height = dimensions.pixel_height,
      last_width = dimensions.pixel_width,
      last_height = dimensions.pixel_height,
      mode = 'hidden',
    }

    wezterm.GLOBAL[state_key] = state
  end

  return state, state_key, dimensions
end

local function apply_background(window, state, state_key, mode)
  state.mode = mode
  wezterm.GLOBAL[state_key] = state

  local overrides = window:get_config_overrides() or {}
  overrides.background = build_background(mode)

  window:set_config_overrides(overrides)
end

-- ---------------------------------------------------------------------------
-- Configuration reload
-- ---------------------------------------------------------------------------

-- Preserve startup state across configuration reloads.
wezterm.on('window-config-reloaded', function(window)
  get_background_state(window)
end)

-- ---------------------------------------------------------------------------
-- Window resize
-- ---------------------------------------------------------------------------

wezterm.on('window-resized', function(window)
  local state, state_key, dimensions = get_background_state(window)

  -- Only automatically change the background on the first real resize.
  if not state.first_open then
    return
  end

  -- Ignore events that did not change the window's pixel dimensions.
  if dimensions.pixel_width == state.last_width
    and dimensions.pixel_height == state.last_height then
    return
  end

  -- Consume the first resize before applying overrides.
  state.first_open = false
  state.last_width = dimensions.pixel_width
  state.last_height = dimensions.pixel_height
  wezterm.GLOBAL[state_key] = state

  local is_startup_size =
    dimensions.pixel_width == state.initial_width
    and dimensions.pixel_height == state.initial_height

  local desired_mode = 'hidden'

  if not is_startup_size then
    if transparent_flag then
      desired_mode = 'transparent'
    elseif bg_image then
      desired_mode = 'image'
    end
  end

  if state.mode == desired_mode then
    return
  end

  apply_background(window, state, state_key, desired_mode)
end)

-- ---------------------------------------------------------------------------
-- Toggle transparency
-- ---------------------------------------------------------------------------

wezterm.on('toggle-background', function(window)
  local state, state_key = get_background_state(window)

  if state.mode == 'transparent' then
    apply_background(
      window,
      state,
      state_key,
      bg_image and 'image' or 'hidden'
    )
  else
    apply_background(window, state, state_key, 'transparent')
  end
end)

-- ---------------------------------------------------------------------------
-- Cycle background image
-- ---------------------------------------------------------------------------

wezterm.on('cycle-background', function(window)
  if #backgrounds == 0 then
    wezterm.log_warn(
      'No supported background images found in: ' .. background_dir
    )
    return
  end

  -- Advance to the next background, wrapping back to the first.
  background_index = background_index % #backgrounds + 1
  bg_image = backgrounds[background_index]

  -- Persist this selection so it is restored on the next WezTerm launch.
  save_selected_background(bg_image)

  local state, state_key = get_background_state(window)

  -- Immediately switch to image mode so the newly selected
  -- background is visible.
  apply_background(window, state, state_key, 'image')
end)

-- ---------------------------------------------------------------------------
-- Font size toggle
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Keybindings
-- ---------------------------------------------------------------------------

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

  -- Toggle image/transparent background.
  {
    key = '.',
    mods = 'ALT',
    action = wezterm.action.EmitEvent 'toggle-background',
  },

  -- Toggle normal/compact font size.
  {
    key = ',',
    mods = 'ALT',
    action = wezterm.action.EmitEvent 'font-size-switch',
  },

  -- Cycle to the next background image.
  {
    key = '/',
    mods = 'ALT',
    action = wezterm.action.EmitEvent 'cycle-background',
  },
}

return config

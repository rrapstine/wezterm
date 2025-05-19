-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Pull in plugins
-- local bar = wezterm.plugin.require 'https://github.com/adriankarlen/bar.wezterm'
-- local bar_config = require 'plugins/bar'

-- Create a variable for the multiplexer layer
local mux = wezterm.mux

-- Check if current OS is MacOS Silicon
local is_macos = wezterm.target_triple:find 'apple%-darwin'

-- Set local PATH on MacOS
if is_macos then
  config.set_environment_variables = {
    PATH = '/opt/homebrew/bin:' .. os.getenv 'PATH',
  }
end

-- Set the color scheme
config.color_scheme = 'catppuccin-mocha'

-- Maximize the window on startup
wezterm.on('gui-startup', function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

-- Smoother animation
config.max_fps = 120

-- Window configuration
config.window_background_opacity = 0.9
config.window_decorations = 'RESIZE'
config.window_padding = config.window_padding or {}
config.window_padding.left = 4
config.window_padding.right = 4
config.window_padding.top = 4
config.window_padding.bottom = 4

config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32

config.colors = config.colors or {}
config.colors.tab_bar = config.colors.tab_bar or {}
config.colors.tab_bar.background = 'transparent'

config.status_update_interval = 500

-- Set blur on MacOS
if is_macos then
  config.macos_window_background_blur = 10
end

-- Font settings
config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 12
config.line_height = 1.2

-- Give the tab bar a different font to stand out
config.window_frame = {
  font = wezterm.font { family = 'Noto Sans', weight = 'Regular' },
}

-- Set inactive panes to be slightly darker
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}

-- Key bindings
config.keys = {
  {
    key = ',',
    mods = 'ALT',
    action = wezterm.action.SpawnCommandInNewWindow {
      cwd = wezterm.home_dir,
      args = { 'nvim', wezterm.config_file },
    },
  },
  { key = 'r', mods = 'ALT', action = wezterm.action.ReloadConfiguration },
  { key = 'n', mods = 'ALT', action = wezterm.action.SpawnWindow },
  { key = 't', mods = 'ALT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'q', mods = 'ALT', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { key = '[', mods = 'ALT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = ']', mods = 'ALT', action = wezterm.action.ActivateTabRelative(1) },
  { key = '"', mods = 'ALT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'ALT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'ALT', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SHIFT|CTRL', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'SHIFT|CTRL', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'SHIFT|CTRL', action = wezterm.action.ActivatePaneDirection 'Down' },
  {
    key = 'F12',
    action = wezterm.action_callback(function(_, pane)
      local tab = pane:tab()
      local panes = tab:panes_with_info()
      if #panes == 1 then
        pane:split {
          direction = 'Right',
          size = 0.4,
        }
      elseif not panes[1].is_zoomed then
        panes[1].pane:activate()
        tab:set_zoomed(true)
      elseif panes[1].is_zoomed then
        tab:set_zoomed(false)
        panes[2].pane:activate()
      end
    end),
  },
}

-- Initialize plugins
-- bar.apply_to_config(config, bar_config)
require 'plugins/tabline'

-- Return the configuration to wezterm
return config

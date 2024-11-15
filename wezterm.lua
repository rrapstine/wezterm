-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Pull in plugins
local bar = wezterm.plugin.require 'https://github.com/adriankarlen/bar.wezterm'

-- Create a variable for the multiplexer layer
local mux = wezterm.mux

-- Set local PATH
-- This is needed on MacOS since Finder does not pass $PATH to Wezterm
-- TODO: Check the OS so that this is only done on MacOS
-- config.set_environment_variables = {
--   PATH = '/opt/homebrew/bin:' .. os.getenv 'PATH',
-- }

-- Set the color scheme
config.color_scheme = 'catppuccin-mocha'

-- Maximize the window on startup
wezterm.on('gui-startup', function()
  local tab, pane, window = mux.spawn_window {}
  window:gui_window():maximize()
end)

-- Window configuration
config.window_background_opacity = 0.8
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

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
  { key = 'R', mods = 'ALT', action = wezterm.action.ReloadConfiguration },
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
bar.apply_to_config(config)

-- Return the configuration to wezterm
return config

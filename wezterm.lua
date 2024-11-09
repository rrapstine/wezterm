-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Set local PATH
-- This is needed on MacOS since Finder does not pass $PATH to Wezterm
-- TODO: Check the OS so that this is only done on MacOS
config.set_environment_variables = {
  PATH = '/opt/homebrew/bin:' .. os.getenv 'PATH',
}

-- This is where you actually apply your config choices
config.keys = {
  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action.SpawnCommandInNewWindow {
      cwd = wezterm.home_dir,
      args = { 'nvim', wezterm.config_file },
    },
  },
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

-- For example, changing the color scheme:
config.color_scheme = 'catppuccin-macchiato'

-- and finally, return the configuration to wezterm
return config

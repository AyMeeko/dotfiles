local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Macchiato'
config.font_size = 13.0
config.font = wezterm.font {
  family = 'Fira Code',
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
}
config.line_height = 1.2
config.hide_tab_bar_if_only_one_tab = true
config.term = "xterm-256color"
config.automatically_reload_config = true
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.initial_rows = 40
config.initial_cols = 200

wezterm.on('gui-startup', function(cmd) -- set startup Window position
  local tab, pane, window = mux.spawn_window(cmd or
    {position={x=1500,y=800}}
  )
end)

config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey {
      key = 'b',
      mods = 'ALT',
    },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'f', mods = 'ALT' },
  },
}

return config

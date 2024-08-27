local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Catppuccin Macchiato'
config.font_size = 16.0
config.font = wezterm.font_with_fallback({
  {
    family = "Cascadia Code",
    harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  },
  "Symbols Nerd Font Mono"
})
config.freetype_load_target = 'Normal'
config.freetype_render_target = 'Normal'
config.line_height = 1.1
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

config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendKey {
      key = 'b',
      mods = 'ALT',
    },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendKey { key = 'f', mods = 'ALT' },
  },
}

return config

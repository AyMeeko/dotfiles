-- Personal bindings load after Omarchy's defaults.
-- Physical Option = SUPER; physical Command = ALT in the shared KMonad map.
local preset_command = 'python3 "$HOME/.config/hypr/window-presets.py" '

o.bind("SUPER + ALT + SHIFT + H", "Window preset: large left", preset_command .. "left")
o.bind("SUPER + ALT + CTRL + F", "Window preset: small center", preset_command .. "small")
o.bind("SUPER + ALT + SHIFT + K", "Window preset: large center", preset_command .. "large")
o.bind("SUPER + ALT + SHIFT + L", "Window preset: large right", preset_command .. "right")

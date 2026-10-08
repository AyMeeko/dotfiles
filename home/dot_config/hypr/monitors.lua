-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.

-- wide screen Dell
hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = 1 })

-- travel monitor (streaming)
hl.monitor({ output = "DP-3", mode = "1920x1080", position = "960x1600", scale = 1 })

-- travel monitors (not streaming)
-- hl.monitor({ output = "DP-3", mode = "preferred", position = "640x1600", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

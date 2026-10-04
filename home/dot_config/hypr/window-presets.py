"""Place a floating window in a centered region of its current monitor."""
import argparse
import json
import re
import subprocess
import sys

# Large: 2250x1542; small: 1620x1156 on a 3840x1600 display with a 26px top bar.
LARGE_HEIGHT_FRACTION = 0.98
LARGE_ASPECT_RATIO = 2250 / 1542
SMALL_WIDTH_SCALE = 0.72
SMALL_HEIGHT_SCALE = 0.75
EDGE_MARGIN = 16


def geometry(monitor, preset):
    """Return logical desktop x, y, width, height, respecting scale and panels."""
    width = round(monitor["width"] / monitor["scale"])
    height = round(monitor["height"] / monitor["scale"])
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    left, top, right, bottom = monitor.get("reserved", [0, 0, 0, 0])
    usable_width = width - left - right
    usable_height = height - top - bottom
    if min(usable_width, usable_height) <= EDGE_MARGIN * 2:
        raise ValueError("Monitor usable area is too small for window presets")
    origin_x = monitor["x"] + left
    origin_y = monitor["y"] + top

    large_height = min(round(usable_height * LARGE_HEIGHT_FRACTION), usable_height - EDGE_MARGIN * 2)
    large_width = min(round(large_height * LARGE_ASPECT_RATIO), usable_width - EDGE_MARGIN * 2)
    # Keep the same aspect ratio when fitting a narrower display.
    large_height = min(large_height, round(large_width / LARGE_ASPECT_RATIO))
    large_width -= large_width % 2  # Equal halves, with no overlap or gap.
    large_x = origin_x + (usable_width - large_width) // 2
    large_y = origin_y + (usable_height - large_height) // 2

    if preset == "small":
        window_width = round(large_width * SMALL_WIDTH_SCALE)
        window_height = round(large_height * SMALL_HEIGHT_SCALE)
        return (origin_x + (usable_width - window_width) // 2,
                origin_y + (usable_height - window_height) // 2,
                window_width, window_height)
    if preset == "large":
        return large_x, large_y, large_width, large_height
    if preset in ("left", "right"):
        half_width = large_width // 2
        return large_x + (half_width if preset == "right" else 0), large_y, half_width, large_height
    raise ValueError(f"Unknown preset: {preset}")


def query(name):
    return json.loads(subprocess.check_output(["hyprctl", "-j", name], text=True))


def place(window, rectangle):
    address = window["address"]
    if not re.fullmatch(r"0x[0-9a-fA-F]+", address):
        raise ValueError("Invalid window address")
    x, y, width, height = rectangle
    # Address every operation to the captured window, even if focus changes.
    # Use the current Lua dispatch API, rather than legacy hyprlang dispatchers.
    commands = [f'local target = "address:{address}"']
    if window.get("fullscreen", 0) or window.get("fullscreenClient", 0):
        commands.append('hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, action = "set", window = target }))')
    commands.extend([
        'hl.dispatch(hl.dsp.window.float({ action = "enable", window = target }))',
        f'hl.dispatch(hl.dsp.window.resize({{ x = {width}, y = {height}, relative = false, window = target }}))',
        f'hl.dispatch(hl.dsp.window.move({{ x = {x}, y = {y}, relative = false, window = target }}))',
    ])
    result = subprocess.run(["hyprctl", "eval", "; ".join(commands)],
                            check=True, capture_output=True, text=True)
    if result.stdout.strip() != "ok":
        raise RuntimeError(result.stdout.strip() or result.stderr.strip())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("preset", choices=("large", "small", "left", "right"))
    parser.add_argument("--address", help="Place this window instead of the focused one")
    parser.add_argument("--dry-run", action="store_true", help="Print geometry without moving a window")
    args = parser.parse_args()
    if args.address:
        if not re.fullmatch(r"0x[0-9a-fA-F]+", args.address):
            raise ValueError("Invalid window address")
        window = next((item for item in query("clients") if item["address"] == args.address), {})
    else:
        window = query("activewindow")
    if not window.get("address") or not window.get("mapped", False):
        return
    monitor = next((item for item in query("monitors") if item["id"] == window["monitor"]), None)
    if monitor is None:
        raise ValueError("Active window's monitor was not found")
    rectangle = geometry(monitor, args.preset)
    if args.dry_run:
        print(json.dumps(dict(zip(("x", "y", "width", "height"), rectangle))))
    else:
        place(window, rectangle)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, RuntimeError, subprocess.CalledProcessError, OSError) as error:
        print(f"Window preset: {error}", file=sys.stderr)
        sys.exit(1)

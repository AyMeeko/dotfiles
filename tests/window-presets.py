"""Check monitor-aware preset geometry without needing a running compositor."""
import importlib.util
from pathlib import Path
import unittest

source = Path(__file__).resolve().parents[1] / "home/dot_config/hypr/window-presets.py"
spec = importlib.util.spec_from_file_location("window_presets", source)
presets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(presets)


class GeometryTests(unittest.TestCase):
    def test_shared_centered_region(self):
        monitor = dict(width=3840, height=1600, scale=1, x=0, y=0, reserved=[0, 26, 0, 0])
        x, y, width, height = presets.geometry(monitor, "large")
        self.assertAlmostEqual(width, 2250, delta=4)
        self.assertEqual(y, 26 + presets.EDGE_MARGIN)
        self.assertEqual(y + height, 1600 - presets.EDGE_MARGIN)
        self.assertEqual(x * 2 + width, 3840)
        self.assertLessEqual(abs(y * 2 + height - (1600 + 26)), 1)
        self.assertEqual(presets.geometry(monitor, "left"), (x, y, width // 2, height))
        self.assertEqual(presets.geometry(monitor, "right"), (x + width // 2, y, width // 2, height))
        sx, sy, sw, sh = presets.geometry(monitor, "small")
        self.assertAlmostEqual(sw, 1350 * 1.2, delta=1)
        self.assertAlmostEqual(sh, 1051 * 1.1, delta=1)
        self.assertLess(sw, width)
        self.assertLess(sh, height)
        self.assertLessEqual(abs(sx * 2 + sw - 3840), 1)
        self.assertLessEqual(abs(sy * 2 + sh - (1600 + 26)), 1)

    def test_scaled_offset_and_rotated_monitors(self):
        # A negative-coordinate monitor, plus rotated/narrow displays and panels.
        for transform in (0, 1, 3, 4, 5, 7):
            monitor = dict(width=2560, height=1440, scale=1.25, x=-2048, y=180,
                           transform=transform, reserved=[30, 40, 20, 10])
            logical_width, logical_height = 2048, 1152
            if transform % 2:
                logical_width, logical_height = logical_height, logical_width
            for preset in ("large", "small", "left", "right"):
                x, y, width, height = presets.geometry(monitor, preset)
                self.assertGreaterEqual(x, -2048 + 30)
                self.assertGreaterEqual(y, 180 + 40)
                self.assertLessEqual(x + width, -2048 + logical_width - 20)
                self.assertLessEqual(y + height, 180 + logical_height - 10)
                self.assertGreater(min(width, height), 0)

    def test_bad_preset(self):
        with self.assertRaises(ValueError):
            presets.geometry(dict(width=1920, height=1080, scale=1, x=0, y=0), "unknown")


if __name__ == "__main__":
    unittest.main()

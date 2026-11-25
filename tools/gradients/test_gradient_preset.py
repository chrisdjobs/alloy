"""Unit tests for the derived Home glow.

Run from the repo root:
``python3 -m unittest discover -s tools/gradients -p "test_*.py"``.
"""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import gradient_preset as gp


def _raw_preset(center_x: float = 0.1, color: str = "#FFB300") -> dict:
    return {
        "id": "test",
        "base": "#0D0D0D",
        "layers": [
            {
                "center": [center_x, -0.55],
                "radius": 1.3,
                "stops": [
                    {"color": color, "position": 0.0, "alpha": 0.34},
                    {"color": color, "position": 0.5, "alpha": 0.12},
                    {"color": color, "position": 1.0, "alpha": 0.0},
                ],
            },
            {
                "center": [0.0, 0.0],
                "radius": 0.8,
                "stops": [
                    {"color": "#FF5A1F", "position": 0.0, "alpha": 0.2},
                    {"color": "#FF5A1F", "position": 1.0, "alpha": 0.0},
                ],
            },
        ],
        "home": {
            "center": [0.0, -0.5],
            "radius": 2.0,
            "stops": [
                {"color": "#00FF00", "position": 0.0, "alpha": 1.0},
                {"color": "#00FF00", "position": 1.0, "alpha": 1.0},
            ],
        },
        "pill": {
            "center": [0.0, 0.0],
            "radius": 2.0,
            "stops": [
                {"color": color, "position": 0.0, "alpha": 1.0},
                {"color": color, "position": 1.0, "alpha": 1.0},
            ],
        },
    }


class DeriveGlowTest(unittest.TestCase):
    def test_one_glow_layer_per_icon_layer(self):
        preset = gp.normalize_preset(_raw_preset())
        self.assertEqual(len(preset["glow"]), len(preset["layers"]))

    def test_every_stop_keeps_its_source_layer_rgb(self):
        preset = gp.normalize_preset(_raw_preset())
        for layer, glow in zip(preset["layers"], preset["glow"]):
            self.assertEqual(
                [stop["color"] for stop in glow["stops"]],
                [stop["color"] for stop in layer["stops"]],
            )

    def test_alphas_stay_in_range_and_keep_their_positions(self):
        preset = gp.normalize_preset(_raw_preset())
        for layer, glow in zip(preset["layers"], preset["glow"]):
            for source, stop in zip(layer["stops"], glow["stops"]):
                self.assertLessEqual(stop["alpha"], 1.0)
                self.assertGreaterEqual(stop["alpha"], 0.0)
                self.assertEqual(stop["position"], source["position"])
            self.assertEqual(glow["stops"][-1]["alpha"], 0.0)

    def test_centers_stay_inside_the_unit_square(self):
        for center_x in (-1.0, -0.95, 0.0, 0.95, 1.0):
            preset = gp.normalize_preset(_raw_preset(center_x=center_x))
            for glow in preset["glow"]:
                self.assertTrue(all(-1 <= value <= 1 for value in glow["center"]))

    def test_x_is_clamped_to_the_glow_box(self):
        self.assertEqual(
            gp.normalize_preset(_raw_preset(center_x=-0.95))["glow"][0]["center"][0],
            -gp.GLOW_MAX_X,
        )
        self.assertEqual(
            gp.normalize_preset(_raw_preset(center_x=0.95))["glow"][0]["center"][0],
            gp.GLOW_MAX_X,
        )

    def test_same_input_gives_the_same_output(self):
        preset = gp.normalize_preset(_raw_preset())
        self.assertEqual(gp.derive_glow(preset), gp.derive_glow(preset))

    def test_normalize_overwrites_the_glow_and_drops_old_fields(self):
        raw = _raw_preset()
        raw["glow"] = [
            {
                "center": [0.0, 0.0],
                "radius": 2.0,
                "stops": [
                    {"color": "#00FF00", "position": 0.0, "alpha": 1.0},
                    {"color": "#00FF00", "position": 1.0, "alpha": 1.0},
                ],
            }
        ]
        preset = gp.normalize_preset(raw)

        self.assertEqual(preset["glow"], gp.derive_glow(preset))
        self.assertNotIn("home", preset)
        self.assertNotIn("pill", preset)
        self.assertTrue(
            all(
                stop["color"] != "#00FF00"
                for layer in preset["glow"]
                for stop in layer["stops"]
            )
        )

    def test_normalize_accepts_old_files_without_home(self):
        raw = _raw_preset()
        del raw["home"]
        preset = gp.normalize_preset(raw)
        self.assertEqual(preset["glow"], gp.derive_glow(preset))

    def test_normalize_accepts_old_files_without_home(self):
        raw = _raw_preset()
        del raw["home"]
        preset = gp.normalize_preset(raw)
        self.assertEqual(preset["glow"], gp.derive_glow(preset))


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Preview the Home/Me glow of a preset without an emulator.

The renderer mirrors what Flutter paints:

* every glow layer is a ``RadialGradient`` stretched to the box width, so its
  horizontal radius is ``radius * width`` and its vertical radius is
  ``radius * height`` (see ``PresetGlow``),
* layers are composited source-over, colors interpolated un-premultiplied,
* a vertical alpha mask (``GLOW_FADE``) fades the whole stack to nothing,
  exactly what the ``ShaderMask`` with ``BlendMode.dstIn`` does in the app.

The glow itself comes from ``gradient_preset.derive_glow``; this script only
draws it. Use it before touching Flutter.

Usage: python3 tools/gradients/preview_home.py <preset.json|png> [--out file]
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

import gradient_preset as gp


def _lerp(stops: list[dict], t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    positions = np.array([s["position"] for s in stops])
    alphas = np.array([s["alpha"] for s in stops])
    rgb = np.array([gp.parse_hex(s["color"]) for s in stops], dtype=np.float32)
    color = np.stack([np.interp(t, positions, rgb[:, i]) for i in range(3)], -1)
    return color, np.interp(t, positions, alphas)


def render_screen(
    preset: dict,
    width: int = 720,
    height: int = 1600,
    glow_height: int = 620,
) -> np.ndarray:
    """Mock a screen: page base color with the glow painted at the top."""
    xs = (np.arange(width, dtype=np.float32) + 0.5)[None, :]
    ys = (np.arange(glow_height, dtype=np.float32) + 0.5)[:, None]
    premultiplied = np.zeros((glow_height, width, 3), np.float32)
    coverage = np.zeros((glow_height, width), np.float32)

    for layer in gp.derive_glow(preset):
        cx = (layer["center"][0] + 1) / 2 * width
        cy = (layer["center"][1] + 1) / 2 * glow_height
        distance = np.sqrt(
            ((xs - cx) / (layer["radius"] * width)) ** 2
            + ((ys - cy) / (layer["radius"] * glow_height)) ** 2
        )
        color, alpha = _lerp(layer["stops"], np.clip(distance, 0, 1))
        premultiplied = premultiplied * (1 - alpha[..., None]) + color * alpha[..., None]
        coverage = coverage * (1 - alpha) + alpha

    positions = [p for p, _ in gp.GLOW_FADE]
    values = [v for _, v in gp.GLOW_FADE]
    mask = np.interp((np.arange(glow_height) + 0.5) / glow_height, positions, values)
    mask = mask.astype(np.float32)[:, None]

    page = np.empty((height, width, 3), np.float32)
    page[:] = np.array(gp.parse_hex(preset["base"]), dtype=np.float32)
    page[:glow_height] = (
        page[:glow_height] * (1 - (coverage * mask)[..., None])
        + premultiplied * mask[..., None]
    )
    return np.clip(page, 0, 255).astype(np.uint8)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="preset .json or candidate .png")
    parser.add_argument("--out", type=Path, help="output PNG")
    args = parser.parse_args()

    preset = gp.load_preset(args.source)
    out = args.out or Path("memory/gradients/previews") / f"{preset['id']}_home.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(render_screen(preset)[:760]).save(out)
    print(out)


if __name__ == "__main__":
    try:
        main()
    except gp.PresetError as error:
        gp.fail(str(error))

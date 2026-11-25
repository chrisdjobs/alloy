#!/usr/bin/env python3
"""Generate candidate gradient presets (JSON + self-describing PNG preview).

The layout is random, the palette is yours: no color outside ``--colors`` is
invented. Each PNG embeds its full preset in a text chunk, so
``apply_gradient.py candidate.png`` needs nothing else. Pillow and numpy only.
"""

from __future__ import annotations

import argparse
import colorsys
import random
import re
from pathlib import Path

import numpy as np
from PIL import Image

import gradient_preset as gp

DEFAULT_OUT = Path("memory/gradients/candidates")
_IMAGE_SAMPLES = 96


def parse_palette(text: str) -> list[str]:
    """Parse a comma-separated palette, keeping the first spelling."""
    colors = []
    for chunk in text.split(","):
        color = gp.parse_hex(chunk.strip())
        hex_color = gp.format_hex(color)
        if hex_color not in colors:
            colors.append(hex_color)
    if not colors:
        raise gp.PresetError("the palette is empty")
    return colors


def derive_base(palette: list[str]) -> str:
    """Very dark, slightly tinted by the palette's average hue."""
    average = [
        sum(gp.parse_hex(color)[channel] for color in palette) / len(palette) / 255
        for channel in range(3)
    ]
    hue, _, saturation = colorsys.rgb_to_hls(*average)
    rgb = colorsys.hls_to_rgb(hue, 0.055, min(0.34, saturation * 0.5))
    return gp.format_hex(tuple(max(4, round(value * 255)) for value in rgb))


def _stop(color: str, position: float, alpha: float) -> dict:
    return {
        "color": color,
        "position": round(position, 3),
        "alpha": round(alpha, 3),
    }


def random_preset(rng: random.Random, palette: list[str], preset_id: str) -> dict:
    """Randomize layout only: centers, radii, dominant color and stop positions."""
    base = derive_base(palette)
    dominant = rng.choice(palette)
    accents = [color for color in palette if color != dominant]

    dominant_center = [rng.uniform(-0.55, 0.55), rng.uniform(-0.75, -0.1)]
    layers = [
        {
            "center": [round(value, 3) for value in dominant_center],
            "radius": round(rng.uniform(0.9, 1.35), 3),
            "stops": [
                _stop(dominant, 0, rng.uniform(0.82, 0.96)),
                _stop(dominant, rng.uniform(0.45, 0.65), rng.uniform(0.22, 0.42)),
                _stop(dominant, 1, 0),
            ],
        }
    ]
    accent_count = min(len(accents), rng.randint(1, 2))
    for color in accents[:accent_count]:
        center = _accent_center(rng, dominant_center)
        alpha = rng.uniform(0.32, 0.55)
        layers.append(
            {
                "center": [round(value, 3) for value in center],
                "radius": round(rng.uniform(0.55, 1.0), 3),
                "stops": [
                    _stop(color, 0, alpha),
                    _stop(color, rng.uniform(0.5, 0.7), alpha * 0.35),
                    _stop(color, 1, 0),
                ],
            }
        )

    accent = accents[0] if accents else dominant
    return gp.normalize_preset(
        {
            "id": preset_id,
            "name": preset_id,
            "base": base,
            "layers": layers,
            "render": {
                "grain": round(rng.uniform(0.008, 0.02), 4),
                "seed": rng.randrange(1, 2**31 - 1),
            },
            "icon": None,
        }
    )


def _accent_center(rng: random.Random, dominant: list[float]) -> list[float]:
    """Pick an accent center clear of the dominant one."""
    for _ in range(50):
        center = [rng.uniform(-0.9, 0.9), rng.uniform(-0.85, 0.6)]
        if (center[0] - dominant[0]) ** 2 + (center[1] - dominant[1]) ** 2 > 0.25:
            return center
    return [rng.uniform(-0.9, 0.9), rng.uniform(-0.85, 0.6)]


def image_preset(path: Path, rng: random.Random, preset_id: str) -> dict:
    """Approximate a preset from an image by clustering its colors."""
    with Image.open(path) as image:
        side = min(image.size)
        left = (image.width - side) // 2
        top = (image.height - side) // 2
        sample = image.convert("RGB").crop((left, top, left + side, top + side))
        sample = sample.resize((_IMAGE_SAMPLES, _IMAGE_SAMPLES), Image.Resampling.LANCZOS)

    pixels = np.asarray(sample, dtype=np.float32).reshape(-1, 3)
    labels, centers = _kmeans(pixels, 4, rng)
    coords = np.stack(
        np.meshgrid(
            np.linspace(-1, 1, _IMAGE_SAMPLES),
            np.linspace(-1, 1, _IMAGE_SAMPLES),
        ),
        axis=-1,
    ).reshape(-1, 2)

    clusters = []
    for index, color in enumerate(centers):
        mask = labels == index
        weight = float(mask.mean())
        if not mask.any():
            continue
        centroid = coords[mask].mean(axis=0)
        spread = float(np.linalg.norm(coords[mask] - centroid, axis=1).mean())
        clusters.append(
            {
                "color": gp.format_hex(tuple(round(value) for value in color)),
                "weight": weight,
                "center": [round(float(centroid[0]), 3), round(float(centroid[1]), 3)],
                "spread": spread,
            }
        )

    if len(clusters) < 2:
        raise gp.PresetError(f"{path} does not hold enough color variation")

    clusters.sort(key=lambda cluster: cluster["weight"], reverse=True)
    darkest = min(
        clusters,
        key=lambda cluster: sum(gp.parse_hex(cluster["color"])),
    )
    base_values = gp.parse_hex(darkest["color"])
    base = gp.format_hex(tuple(min(30, value) for value in base_values))

    layers = []
    for cluster in clusters:
        if cluster is darkest:
            continue
        alpha = min(0.9, 0.3 + cluster["weight"] * 0.9)
        layers.append(
            {
                "center": cluster["center"],
                "radius": round(min(1.6, max(0.55, cluster["spread"] * 1.8)), 3),
                "stops": [
                    _stop(cluster["color"], 0, alpha),
                    _stop(cluster["color"], 0.55, alpha * 0.35),
                    _stop(cluster["color"], 1, 0),
                ],
            }
        )
    if not layers:
        raise gp.PresetError(f"{path} has no color besides its background")
    if len(layers) == 1:
        duplicate = layers[0]
        layers.append(
            {
                "center": [0.3, -0.5],
                "radius": 1.2,
                "stops": [
                    _stop(duplicate["stops"][0]["color"], 0, 0.45),
                    _stop(duplicate["stops"][0]["color"], 0.55, 0.15),
                    _stop(duplicate["stops"][0]["color"], 1, 0),
                ],
            }
        )

    return gp.normalize_preset(
        {
            "id": preset_id,
            "name": preset_id,
            "approximate": True,
            "base": base,
            "layers": layers[:3],
            "render": {"grain": 0.012, "seed": rng.randrange(1, 2**31 - 1)},
            "icon": None,
        }
    )


def _kmeans(pixels: np.ndarray, k: int, rng: random.Random) -> tuple[np.ndarray, np.ndarray]:
    """k-means++ with a seeded first pick; small enough to stay dependency-free."""
    generator = np.random.default_rng(rng.randrange(2**31))
    centers = [pixels[generator.integers(len(pixels))]]
    for _ in range(k - 1):
        distances = np.min(
            [((pixels - center) ** 2).sum(axis=1) for center in centers],
            axis=0,
        )
        probabilities = distances / distances.sum()
        centers.append(pixels[generator.choice(len(pixels), p=probabilities)])

    centers_array = np.asarray(centers, dtype=np.float32)
    labels = np.zeros(len(pixels), dtype=np.int64)
    for _ in range(12):
        distances = ((pixels[:, None, :] - centers_array[None, :, :]) ** 2).sum(axis=2)
        labels = distances.argmin(axis=1)
        for index in range(k):
            members = pixels[labels == index]
            if len(members):
                centers_array[index] = members.mean(axis=0)
    return labels, centers_array


def next_index(out: Path) -> int:
    """First ``grad_###`` number not taken in [out]."""
    if not out.is_dir():
        return 1
    taken = [
        int(match.group(1))
        for path in out.iterdir()
        if path.is_file() and (match := re.fullmatch(r"grad_(\d+)", path.stem))
    ]
    return max(taken, default=0) + 1


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--colors", help='palette, e.g. "#FF5A1F,#FFC400,#7B2FF7"')
    parser.add_argument("--count", type=int, default=6, help="candidates to generate")
    parser.add_argument("--seed", type=int, help="seed; random when omitted")
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT, help="output folder")
    parser.add_argument("--from-image", type=Path, help="approximate an old preview")
    parser.add_argument("--name", help="slug for the --from-image candidate")
    args = parser.parse_args()

    if bool(args.colors) == bool(args.from_image):
        gp.fail("pass either --colors or --from-image, not both")
    if args.count < 1 or args.count > 50:
        gp.fail("--count must be between 1 and 50")

    seed = args.seed if args.seed is not None else random.SystemRandom().randrange(2**31)
    rng = random.Random(seed)
    args.out.mkdir(parents=True, exist_ok=True)
    index = next_index(args.out)

    if args.from_image:
        preset_id = gp.slug(args.name) if args.name else f"grad_{index:03d}"
        preset = image_preset(args.from_image, rng, preset_id)
        presets = [preset]
    else:
        palette = parse_palette(args.colors)
        presets = [
            random_preset(rng, palette, f"grad_{index + offset:03d}")
            for offset in range(args.count)
        ]

    for preset in presets:
        json_path = args.out / f"{preset['id']}.json"
        png_path = args.out / f"{preset['id']}.png"
        json_path.write_text(gp.to_json(preset), encoding="utf8")
        gp.write_preview(png_path, preset)
        approx = " (approximate)" if preset["approximate"] else ""
        print(f"{png_path}{approx}")
    print(f"seed={seed}")
    print(
        "Apply one with: python3 tools/gradients/apply_gradient.py "
        f"{args.out / (presets[0]['id'] + '.png')} --set-active"
    )


if __name__ == "__main__":
    try:
        main()
    except gp.PresetError as error:
        gp.fail(str(error))

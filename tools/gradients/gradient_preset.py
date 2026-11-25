"""Preset schema, validation and renderer shared by the gradient tools.

The geometry mirrors Flutter's ``RadialGradient`` exactly:

* ``center`` is an ``Alignment`` in the [-1, 1] square mapped onto the paint
  box, so pixel centers land where Flutter's ``Alignment.withinRect`` puts
  them.
* ``radius`` is a fraction of the paint box's shortest side.
* ``stops`` are positions in [0, 1]; colors interpolate premultiplied, the way
  Skia rasterizes the gradient, so fades do not drift towards another hue.

The same math paints the icon PNG and the nav pill in Flutter. ``glow`` is not
randomized: it reuses the icon's own ``layers`` by [derive_glow], so every
Home/Me build picks up the same colors and old files are re-derived on load.
"""

from __future__ import annotations

import json
import math
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from PIL.PngImagePlugin import PngInfo

SCHEMA = 3
METADATA_KEY = "bars_gradient_preset"
PREVIEW_SIZE = 1024

# Glow knobs: the only place the Home/Me glow is tuned. The glow reuses the
# icon's own layers, re-aimed at a wide, short box: every original y is squeezed
# into GLOW_Y_RANGE, x is clamped so the wash stays on screen, and the alphas
# are scaled down so several layers can add up without clipping. Flutter's
# PresetGlow then fades the whole stack with GLOW_FADE.
GLOW_RADIUS_SCALE = 0.95
GLOW_ALPHA_GAIN = 0.6
GLOW_Y_RANGE = (-0.75, 0.0)  # where the layers' icon-space y lands in the box
GLOW_FADE = ((0.0, 1.0), (0.4, 0.65), (1.0, 0.0))  # (position, alpha) top->bottom
GLOW_MAX_X = 0.9

# Pill knobs: coordinated with the glow. Uses dominant layer color + accent
# layer color so the navbar pill feels like the same visual family.
PILL_CENTER_X = -0.3
PILL_CENTER_Y = -0.6
PILL_RADIUS = 2.0
PILL_STOP_POSITIONS = (0.0, 0.5, 1.0)

_HEX = re.compile(r"^#[0-9a-fA-F]{6}$")
_SLUG = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")


class PresetError(ValueError):
    """A preset is missing data, breaks the schema or is not self-describing."""


def slug(value: object) -> str:
    """Return [value] as a preset slug or raise [PresetError]."""
    text = str(value or "").strip().lower()
    if not _SLUG.match(text):
        raise PresetError(
            f"{value!r} is not a slug; use lowercase letters, digits, '-' or '_'"
        )
    return text


def parse_hex(value: object) -> tuple[int, int, int]:
    """Parse ``#RRGGBB`` into an RGB tuple."""
    if not isinstance(value, str) or not _HEX.match(value):
        raise PresetError(f"{value!r} is not a #RRGGBB color")
    return tuple(int(value[i : i + 2], 16) for i in (1, 3, 5))


def format_hex(rgb: tuple[int, int, int]) -> str:
    """Format an RGB tuple as ``#RRGGBB``."""
    return "#{:02X}{:02X}{:02X}".format(*rgb)


def argb_hex(color: str, alpha: float = 1.0) -> str:
    """Return the 0xAARRGGBB literal Flutter's ``Color`` uses."""
    red, green, blue = parse_hex(color)
    return f"0x{round(alpha * 255):02X}{red:02X}{green:02X}{blue:02X}"


def normalize_preset(raw: object) -> dict:
    """Validate [raw] and return the canonical preset dictionary."""
    if not isinstance(raw, dict):
        raise PresetError("a preset must be a JSON object")

    preset_id = slug(raw.get("id"))
    base = format_hex(parse_hex(raw.get("base")))
    raw_layers = _list(raw.get("layers"), "layers")
    layers = [
        _gradient(item, f"layers[{index}]")
        for index, item in enumerate(raw_layers)
    ]
    if not 2 <= len(layers) <= 3:
        raise PresetError("layers must hold 2 or 3 radial layers")

    render = raw.get("render") or {}
    if not isinstance(render, dict):
        raise PresetError("render must be an object")
    grain = _number(render.get("grain", 0.015), "render.grain")
    if not 0 <= grain <= 0.1:
        raise PresetError("render.grain must be between 0 and 0.1")
    seed = render.get("seed", 0)
    if not isinstance(seed, int):
        raise PresetError("render.seed must be an integer")

    icon = raw.get("icon")
    if icon is not None and not isinstance(icon, dict):
        raise PresetError("icon must be an object or null")

    preset = {
        "schema": SCHEMA,
        "id": preset_id,
        "name": str(raw.get("name") or preset_id),
        "approximate": bool(raw.get("approximate", False)),
        "base": base,
        "layers": layers,
        # Replaced below: glow and pill are always derived, never read from the
        # file. Files from schema 2 may still carry a ``home``; it is ignored.
        "glow": None,
        "pill": None,
        "render": {"grain": round(grain, 4), "seed": seed},
        "icon": icon,
    }
    preset["glow"] = derive_glow(preset)
    preset["pill"] = derive_pill(preset)
    return preset


def derive_glow(preset: dict) -> list[dict]:
    """Glow layers: the icon's own layers, re-aimed at a wide, short box.

    One glow gradient per icon layer, in the same order, so the wash keeps the
    icon's colors left to right. Only the center, the radius and the alphas
    change; every stop keeps its source layer's rgb.
    """
    low, high = GLOW_Y_RANGE
    glow = []
    for layer in preset["layers"]:
        x, y = layer["center"]
        glow.append(
            {
                "center": [
                    round(max(-GLOW_MAX_X, min(GLOW_MAX_X, x)), 4),
                    round(low + (y + 1) / 2 * (high - low), 4),
                ],
                "radius": round(layer["radius"] * GLOW_RADIUS_SCALE, 4),
                "stops": [
                    {
                        "color": stop["color"],
                        "position": stop["position"],
                        "alpha": round(min(1.0, stop["alpha"] * GLOW_ALPHA_GAIN), 4),
                    }
                    for stop in layer["stops"]
                ],
            }
        )
    return glow


def derive_pill(preset: dict) -> dict:
    """Derive the nav pill gradient from the preset's layers.

    Uses the dominant layer (layers[0]) for the start color and the first accent
    layer (layers[1] if present, else layers[0]) for the end color. Both colors
    are at full opacity so the pill is vibrant and coordinates with the glow.
    """
    dominant = preset["layers"][0]
    accent_layer = preset["layers"][1] if len(preset["layers"]) > 1 else dominant
    start_color = dominant["stops"][0]["color"]
    end_color = accent_layer["stops"][0]["color"]

    return {
        "center": [PILL_CENTER_X, PILL_CENTER_Y],
        "radius": PILL_RADIUS,
        "stops": [
            {"color": start_color, "position": PILL_STOP_POSITIONS[0], "alpha": 1.0},
            {"color": end_color, "position": PILL_STOP_POSITIONS[1], "alpha": 1.0},
            {"color": end_color, "position": PILL_STOP_POSITIONS[2], "alpha": 1.0},
        ],
    }


def _gradient(raw: object, where: str) -> dict:
    if not isinstance(raw, dict):
        raise PresetError(f"{where} must be an object")

    center = _list(raw.get("center"), f"{where}.center", length=2)
    alignment = [_number(value, f"{where}.center") for value in center]
    if not all(-1 <= value <= 1 for value in alignment):
        raise PresetError(f"{where}.center must stay inside [-1, 1]")

    radius = _number(raw.get("radius"), f"{where}.radius")
    if not 0.05 <= radius <= 6:
        raise PresetError(f"{where}.radius must be between 0.05 and 6")

    stops = []
    for index, stop in enumerate(_list(raw.get("stops"), f"{where}.stops")):
        if not isinstance(stop, dict):
            raise PresetError(f"{where}.stops[{index}] must be an object")
        position = _number(stop.get("position"), f"{where}.stops[{index}].position")
        alpha = _number(stop.get("alpha", 1.0), f"{where}.stops[{index}].alpha")
        if not 0 <= position <= 1:
            raise PresetError(f"{where}.stops[{index}].position must be in [0, 1]")
        if not 0 <= alpha <= 1:
            raise PresetError(f"{where}.stops[{index}].alpha must be in [0, 1]")
        stops.append(
            {
                "color": format_hex(parse_hex(stop.get("color"))),
                "position": round(position, 4),
                "alpha": round(alpha, 4),
            }
        )

    if len(stops) < 2:
        raise PresetError(f"{where}.stops needs at least 2 stops")
    positions = [stop["position"] for stop in stops]
    if positions[0] != 0 or positions[-1] != 1:
        raise PresetError(f"{where}.stops must start at 0 and end at 1")
    if any(left >= right for left, right in zip(positions, positions[1:])):
        raise PresetError(f"{where}.stops positions must increase")

    return {
        "center": [round(value, 4) for value in alignment],
        "radius": round(radius, 4),
        "stops": stops,
    }


def _list(value: object, where: str, length: int | None = None) -> list:
    if not isinstance(value, list):
        raise PresetError(f"{where} must be a list")
    if length is not None and len(value) != length:
        raise PresetError(f"{where} must hold {length} numbers")
    return value


def _number(value: object, where: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise PresetError(f"{where} must be a number")
    if not math.isfinite(value):
        raise PresetError(f"{where} must be finite")
    return float(value)


def to_json(preset: dict) -> str:
    """Serialize [preset] with a stable key order and a trailing newline."""
    return json.dumps(preset, indent=2, ensure_ascii=True) + "\n"


def load_json_preset(path: Path) -> dict:
    """Read and normalize a preset JSON file."""
    try:
        raw = json.loads(path.read_text(encoding="utf8"))
    except OSError as error:
        raise PresetError(f"could not read {path}: {error}") from error
    except json.JSONDecodeError as error:
        raise PresetError(f"{path} is not valid JSON: {error}") from error
    return normalize_preset(raw)


def read_png_preset(path: Path) -> dict:
    """Read the preset embedded in a preview PNG."""
    try:
        with Image.open(path) as image:
            raw = image.text.get(METADATA_KEY)
    except OSError as error:
        raise PresetError(f"could not read {path}: {error}") from error
    if not raw:
        hint = ""
        twin = path.with_suffix(".json")
        if twin.exists():
            hint = f" Use {twin} instead."
        raise PresetError(
            f"{path.name} has no embedded gradient preset.{hint} "
            "Pass the matching .json, or derive a preset from an image with "
            "generate_gradients.py --from-image."
        )
    try:
        return normalize_preset(json.loads(raw))
    except json.JSONDecodeError as error:
        raise PresetError(f"{path.name} has corrupt preset metadata: {error}") from error


def load_preset(path: Path) -> dict:
    """Load a preset from a .json file or from a PNG's embedded metadata."""
    if not path.is_file():
        raise PresetError(f"{path} does not exist")
    if path.suffix.lower() == ".json":
        return load_json_preset(path)
    if path.suffix.lower() == ".png":
        return read_png_preset(path)
    raise PresetError(f"unsupported preset file {path}; use .json or .png")


def render_preset(preset: dict, size: int) -> np.ndarray:
    """Render the preset's [layers] over ``base`` as an opaque RGB array."""
    canvas = np.empty((size, size, 3), dtype=np.float32)
    canvas[:] = np.array(parse_hex(preset["base"]), dtype=np.float32)

    coords = np.arange(size, dtype=np.float32) + 0.5
    for layer in preset["layers"]:
        source, alpha = _layer_pixels(layer, coords, size)
        canvas = canvas * (1.0 - alpha[..., None]) + source

    return np.clip(canvas, 0, 255).astype(np.uint8)


def _layer_pixels(layer: dict, coords: np.ndarray, size: int) -> tuple[np.ndarray, np.ndarray]:
    center_x = (layer["center"][0] + 1) * 0.5 * size
    center_y = (layer["center"][1] + 1) * 0.5 * size
    radius = layer["radius"] * size

    delta_x = coords[None, :] - center_x
    delta_y = coords[:, None] - center_y
    distance = np.sqrt(delta_x * delta_x + delta_y * delta_y)
    t = np.clip(distance / radius, 0.0, 1.0).astype(np.float32)

    stops = layer["stops"]
    source = np.zeros((size, size, 3), dtype=np.float32)
    alpha = np.zeros((size, size), dtype=np.float32)
    for start, end in zip(stops, stops[1:]):
        first = _premultiplied(start)
        last = _premultiplied(end)
        span = end["position"] - start["position"]
        segment = (t >= start["position"]) & (t <= end["position"])
        blend = ((t[segment] - start["position"]) / span)[:, None]
        source[segment] = first[0] + (last[0] - first[0]) * blend
        alpha[segment] = (first[1] + (last[1] - first[1]) * blend)[:, 0]
    return source, alpha


def _premultiplied(stop: dict) -> tuple[np.ndarray, np.ndarray]:
    alpha = np.float32(stop["alpha"])
    rgb = np.array(parse_hex(stop["color"]), dtype=np.float32) * alpha
    return rgb.reshape(1, 3), np.array([[alpha]], dtype=np.float32)


def apply_grain(rgb: np.ndarray, grain: float, seed: int) -> np.ndarray:
    """Add deterministic monochrome grain to a preview."""
    if grain <= 0:
        return rgb
    generator = np.random.default_rng(seed)
    height, width = rgb.shape[:2]
    noise = generator.normal(0.0, grain * 255.0, size=(height, width, 1))
    return np.clip(rgb.astype(np.float32) + noise, 0, 255).astype(np.uint8)


def write_preview(path: Path, preset: dict) -> None:
    """Write a preview PNG carrying the full preset in a text chunk."""
    rgb = render_preset(preset, PREVIEW_SIZE)
    rgb = apply_grain(rgb, preset["render"]["grain"], preset["render"]["seed"])
    info = PngInfo()
    info.add_text(
        METADATA_KEY,
        json.dumps(preset, separators=(",", ":"), sort_keys=True),
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgb, "RGB").save(path, format="PNG", pnginfo=info)


def fail(message: str) -> None:
    """Print [message] as an error and exit with status 2."""
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(2)

#!/usr/bin/env python3
"""Apply a gradient preset to the icon assets, registry and Dart presets.

The preset comes from the ``.json`` file or from the full preset embedded in a
preview ``.png``. Nothing here judges colors: the script renders, copies the
foreground untouched, checks the adaptive safe zone, updates the registry,
regenerates the Dart file and, with ``--set-active``, points the launcher icon
tooling at the new preset and runs it.

``--refresh`` re-derives the registered presets instead of applying a file:
derived fields such as ``glow`` update, while icon assets and the launcher
config stay as they are.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import shutil
import subprocess
from pathlib import Path

from PIL import Image
from PIL import ImageDraw

import dart_gen
import gradient_preset as gp

REGISTRY = Path("assets/icon/presets.json")
PRESETS_DIR = Path("assets/icon/presets")
DART_FILE = Path("lib/shared/design/gradient_presets.dart")
LAUNCHER_CONFIG = Path("flutter_launcher_icons.yaml")
FOREGROUND = Path("assets/icon/ic_launcher_foreground.png")
MONOCHROME = Path("assets/icon/ic_launcher_monochrome.png")

LEGACY_SIZE = 1024
ADAPTIVE_SIZE = 432
# Both match the hand-made icon this pipeline replaces: a rounded square whose
# foreground content spans 78% of the width.
LEGACY_CORNER = 0.215
LEGACY_CONTENT = 0.78
# Android's 66dp safe circle on the 108dp adaptive canvas.
SAFE_RADIUS = 33 / 108


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "source",
        type=Path,
        nargs="?",
        help="candidate .png or .json; omit with --refresh",
    )
    parser.add_argument("--name", help="preset slug; defaults to the candidate id")
    parser.add_argument("--set-active", action="store_true", help="switch the icon")
    parser.add_argument(
        "--refresh",
        action="store_true",
        help="re-derive every registered preset; takes no source",
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help=argparse.SUPPRESS,
    )
    args = parser.parse_args()

    root = args.project_root.resolve()
    if args.refresh:
        if args.source is not None or args.name or args.set_active:
            gp.fail("--refresh takes no source, --name or --set-active")
        _refresh(root)
        return
    if args.source is None:
        gp.fail("pass a candidate .png or .json, or --refresh")

    preset = gp.load_preset(args.source)
    preset_id = gp.slug(args.name) if args.name else preset["id"]
    preset["id"] = preset_id
    preset["name"] = preset_id

    config_path = root / LAUNCHER_CONFIG
    if not config_path.is_file():
        gp.fail(f"{LAUNCHER_CONFIG} not found under {root}")
    config = config_path.read_text(encoding="utf8")

    preset_dir = PRESETS_DIR / preset_id
    icon = preset.get("icon") or {}
    hand_made = bool(icon.get("hand_made"))
    changed = [f"{preset_dir}/preset.json"]
    if hand_made:
        for key in ("legacy", "adaptive_background", "foreground", "monochrome"):
            value = icon.get(key)
            if not value or not (root / value).is_file():
                gp.fail(f"hand-made icon is missing {key}: {value!r}")
        foreground = root / icon["foreground"]
    else:
        configured = _config_value(config, "adaptive_icon_foreground")
        foreground = root / (
            icon.get("foreground") or configured or FOREGROUND.as_posix()
        )
        if not foreground.is_file():
            gp.fail(f"adaptive foreground {foreground} does not exist")

        legacy_path = preset_dir / "icon_legacy_1024.png"
        background_path = preset_dir / "icon_adaptive_background.png"
        preset["icon"] = {
            "dir": preset_dir.as_posix(),
            "legacy": legacy_path.as_posix(),
            "adaptive_background": background_path.as_posix(),
            "foreground": _relative(foreground, root),
            "monochrome": icon.get("monochrome")
            or _config_value(config, "adaptive_icon_monochrome")
            or MONOCHROME.as_posix(),
        }
        _write_legacy(preset, root / legacy_path, foreground)
        _write_background(preset, root / background_path)
        changed += [legacy_path.as_posix(), background_path.as_posix()]

    (root / preset_dir).mkdir(parents=True, exist_ok=True)
    (root / preset_dir / "preset.json").write_text(
        gp.to_json(preset),
        encoding="utf8",
    )

    registry = _load_registry(root)
    registry["presets"][preset_id] = preset
    if registry.get("active") is None or args.set_active:
        registry["active"] = preset_id
    _write_registry(root, registry)
    dart_gen.write_dart(registry, root / DART_FILE)

    _check_safe_zone(foreground, config)

    changed += [REGISTRY.as_posix(), DART_FILE.as_posix()]
    print(f"Applied preset {preset_id!r} (active: {registry['active']})")
    for path in changed:
        print(f"  {path}")

    if args.set_active:
        _update_launcher_config(config_path, config, preset, root)
        if not _run_launcher_icons(root):
            raise SystemExit(1)


def _refresh(root: Path) -> None:
    """Re-normalize the registry's presets and rewrite the derived outputs."""
    registry = _load_registry(root)
    if not registry["presets"]:
        gp.fail(f"{REGISTRY} holds no presets to refresh")

    refreshed = {}
    for key in sorted(registry["presets"]):
        preset = gp.normalize_preset(registry["presets"][key])
        if preset["id"] != key:
            gp.fail(f"{REGISTRY} preset {key!r} has id {preset['id']!r}")
        refreshed[key] = preset
    registry["presets"] = refreshed
    if registry["active"] not in refreshed:
        gp.fail(
            f"{REGISTRY} is active={registry['active']!r}, "
            "which is not one of its presets"
        )

    _write_registry(root, registry)
    dart_gen.write_dart(registry, root / DART_FILE)
    print(f"Refreshed {len(refreshed)} presets (active: {registry['active']})")
    print(f"  {REGISTRY.as_posix()}")
    print(f"  {DART_FILE.as_posix()}")


def _write_legacy(preset: dict, path: Path, foreground: Path) -> None:
    """1024 legacy icon: gradient, existing foreground, rounded corners."""
    icon = Image.fromarray(gp.render_preset(preset, LEGACY_SIZE), "RGB").convert("RGBA")
    layer = Image.open(foreground).convert("RGBA")
    bounds = layer.getchannel("A").getbbox()
    if bounds is None:
        gp.fail(f"{foreground} is fully transparent")

    scale = LEGACY_SIZE * LEGACY_CONTENT / (bounds[2] - bounds[0])
    size = (round(layer.width * scale), round(layer.height * scale))
    layer = layer.resize(size, Image.Resampling.LANCZOS)
    # Center the visible content, not the transparent canvas of the foreground.
    left = round(LEGACY_SIZE / 2 - (bounds[0] + bounds[2]) / 2 * scale)
    top = round(LEGACY_SIZE / 2 - (bounds[1] + bounds[3]) / 2 * scale)
    icon.paste(layer, (left, top), layer)
    icon.putalpha(_rounded_mask(LEGACY_SIZE, LEGACY_CORNER))

    path.parent.mkdir(parents=True, exist_ok=True)
    icon.save(path, format="PNG")
    print(f"Wrote {path.parent.name}/{path.name}")


def _write_background(preset: dict, path: Path) -> None:
    """Full-bleed adaptive background at the foreground's 108dp size."""
    path.parent.mkdir(parents=True, exist_ok=True)
    image = Image.fromarray(gp.render_preset(preset, ADAPTIVE_SIZE), "RGB")
    image.save(path, format="PNG")


def _rounded_mask(size: int, fraction: float) -> Image.Image:
    """Antialiased rounded-square mask."""
    supersample = 4
    large = size * supersample
    mask = Image.new("L", (large, large), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, large - 1, large - 1),
        radius=round(fraction * large),
        fill=255,
    )
    return mask.resize((size, size), Image.Resampling.LANCZOS)


def _check_safe_zone(foreground: Path, config: str) -> None:
    """Warn, never resize, when the foreground leaves Android's safe circle."""
    inset = _config_value(config, "adaptive_icon_foreground_inset") or "16"
    try:
        inset_fraction = float(inset) / 100
    except ValueError:
        inset_fraction = 0.16

    with Image.open(foreground) as image:
        bounds = image.getchannel("A").getbbox()
        width, height = image.size
    if bounds is None:
        gp.fail(f"{foreground} is fully transparent")

    scale = 1 - 2 * inset_fraction
    points = [
        (x, y)
        for x in (bounds[0], bounds[2] - 1)
        for y in (bounds[1], bounds[3] - 1)
    ]
    worst = max(
        math.hypot(((x / width) - 0.5) * scale, ((y / height) - 0.5) * scale)
        for x, y in points
    )
    if worst > SAFE_RADIUS:
        print(
            f"warning: the adaptive foreground leaves the safe circle "
            f"({worst * 100:.0f}% of the canvas, safe is {SAFE_RADIUS * 100:.1f}%); "
            "some launchers will crop it",
        )
    else:
        print(f"Adaptive foreground inside the safe circle ({worst * 100:.0f}%).")


def _load_registry(root: Path) -> dict:
    path = root / REGISTRY
    if not path.exists():
        return {"schema": gp.SCHEMA, "active": None, "presets": {}}
    try:
        raw = json.loads(path.read_text(encoding="utf8"))
    except json.JSONDecodeError as error:
        gp.fail(f"{REGISTRY} is not valid JSON: {error}")
    presets = raw.get("presets")
    if not isinstance(presets, dict):
        gp.fail(f"{REGISTRY} has no presets object")
    return {"schema": gp.SCHEMA, "active": raw.get("active"), "presets": presets}


def _write_registry(root: Path, registry: dict) -> None:
    ordered = {
        "schema": gp.SCHEMA,
        "active": registry["active"],
        "presets": {
            key: registry["presets"][key] for key in sorted(registry["presets"])
        },
    }
    (root / REGISTRY).write_text(gp.to_json(ordered), encoding="utf8")


def _config_value(config: str, key: str) -> str | None:
    match = re.search(
        rf'^\s*{re.escape(key)}:\s*"?([^"#\n]*?)"?\s*$',
        config,
        re.MULTILINE,
    )
    return match.group(1).strip() if match and match.group(1).strip() else None


def _update_launcher_config(
    path: Path,
    config: str,
    preset: dict,
    root: Path,
) -> None:
    icon = preset["icon"]
    updated = _set_config_value(config, "image_path", icon["legacy"])
    updated = _set_config_value(
        updated,
        "adaptive_icon_background",
        icon["adaptive_background"],
    )
    updated = _set_config_value(
        updated,
        "adaptive_icon_foreground",
        icon["foreground"],
    )
    updated = _set_config_value(
        updated,
        "adaptive_icon_monochrome",
        icon["monochrome"],
    )
    path.write_text(updated, encoding="utf8")
    print(f"Updated {_relative(path, root)}")


def _set_config_value(config: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^(\s*){re.escape(key)}:\s*.*$', re.MULTILINE)
    line = f'{key}: "{value}"'
    if pattern.search(config):
        return pattern.sub(lambda match: f"{match.group(1)}{line}", config, count=1)
    header = "flutter_launcher_icons:"
    if header not in config:
        gp.fail(f"{LAUNCHER_CONFIG} has no flutter_launcher_icons block")
    return config.replace(header, f"{header}\n  {line}", 1)


def _run_launcher_icons(root: Path) -> bool:
    dart = shutil.which("dart") or str(Path.home() / "flutter/bin/dart")
    command = [dart, "run", "flutter_launcher_icons"]
    print("Running: " + " ".join(command))
    result = subprocess.run(command, cwd=root, capture_output=True, text=True)
    output = (result.stdout + result.stderr).strip()
    if output:
        print("\n".join(output.splitlines()[-12:]))
    if result.returncode != 0:
        print(
            f"error: flutter_launcher_icons exited with {result.returncode}",
            flush=True,
        )
        return False
    return True


def _relative(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


if __name__ == "__main__":
    try:
        main()
    except gp.PresetError as error:
        gp.fail(str(error))

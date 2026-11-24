# Gradient presets

One JSON preset is the source of truth for the app icon, the adaptive icon
background, the Home gradient and the nav pill. The Python renderer mirrors
Flutter's `RadialGradient` math, so the icon PNG and the Flutter gradients agree:

- `center` is an `Alignment` in `[-1, 1]`, mapped onto the paint box.
- `radius` is a fraction of the paint box's shortest side.
- `stops` are positions in `[0, 1]`; colors interpolate premultiplied (Skia).

Requires Python 3, Pillow and numpy. Run every command from the repo root.

## Generate candidates

```bash
python3 tools/gradients/generate_gradients.py \
  --colors "#FF5A1F,#FFC400,#7B2FF7" \
  --count 8 --seed 7 \
  --out memory/gradients/candidates/
```

Writes `grad_001.json` + `grad_001.png` (and so on) with your palette only. The
base is derived dark and slightly tinted; layout, dominant color and stop
positions are seeded, and the grain lives in the PNG only. Each PNG embeds its
full preset in a text chunk, so the PNG alone is enough to apply it. New runs
continue after the highest `grad_###` already in the folder instead of
overwriting it. Without `--seed` the run picks one and prints it.

Approximate a preset from an old preview:

```bash
python3 tools/gradients/generate_gradients.py \
  --from-image memory/gradients/1/grad_3.png \
  --seed 1 --out memory/gradients/candidates/
```

The output is a re-render of the derived preset, marked `"approximate": true`.

## Apply a preset

```bash
# Normal path: the PNG carries the preset.
python3 tools/gradients/apply_gradient.py \
  memory/gradients/candidates/grad_003.png --set-active

# Rename while applying; the slug becomes the preset id.
python3 tools/gradients/apply_gradient.py \
  memory/gradients/candidates/grad_003.png --name sunset --set-active

# A JSON does the same; without --set-active it is registered but stays inactive.
python3 tools/gradients/apply_gradient.py \
  memory/gradients/candidates/grad_003.json
```

A PNG without embedded metadata stops with an error: pass the matching `.json`
or derive one with `--from-image`. The script never guesses a preset.

`--set-active` rewrites `flutter_launcher_icons.yaml` to the preset's legacy and
adaptive-background files, keeps the existing foreground/monochrome untouched,
and runs `dart run flutter_launcher_icons`. The Android manifest is not touched.

## Where things land

| Path | What | Git |
| --- | --- | --- |
| `memory/gradients/candidates/` | generator output | ignored |
| `assets/icon/presets.json` | registry: every applied preset + `active` | tracked |
| `assets/icon/presets/<name>/preset.json` | the applied preset as given | tracked |
| `assets/icon/presets/<name>/icon_legacy_1024.png` | legacy icon, rounded corners | tracked |
| `assets/icon/presets/<name>/icon_adaptive_background.png` | 432 px adaptive background | tracked |
| `lib/shared/design/gradient_presets.dart` | generated Dart data | tracked, never edited |

The script also checks the existing foreground against Android's 66dp safe
circle and warns without resizing it. Applying the same name again updates it in
place and rewrites identical bytes, so the flow is idempotent.

In the app, read `AppGradientPresets.active` (or the
`activeGradientPresetProvider`) for `base`, `home` and `pill`. The agent-facing
checklist lives in `.opencode/skills/gradient-preset/SKILL.md`.

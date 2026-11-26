# Gradient presets

One JSON preset is the source of truth for the page base, the Home/Me glow and
the nav pill, and it carries the icon paths used by the launcher. The icon can be
rendered from the preset's own layers and foreground, or hand-made
(`"hand_made": true` in the `icon` block). The Python renderer mirrors Flutter's
`RadialGradient` math, so the icon PNG and the Flutter gradients agree:

- `center` is an `Alignment` in `[-1, 1]`, mapped onto the paint box.
- `radius` is a fraction of the paint box's shortest side.
- `stops` are positions in `[0, 1]`; colors interpolate premultiplied (Skia).

`glow` is not random and never hand-edited: `derive_glow` rebuilds it from the
icon's own `layers`, one glow layer per icon layer, so the wash keeps the icon's
colors left to right. Only the center (squeezed into the top half, x clamped),
the radius and the alphas change; every stop keeps its source layer's rgb. Its
knobs are the `GLOW_*` constants in `gradient_preset.py` — the glow has no
other tuning. The nav pill and the Me identity card reuse the same `glow`.
Schema 5 is the only derived gradient; old files with a `home` (schema 2) or a
`pill` (schemas 3-4) are accepted and those keys are ignored.

Requires Python 3, Pillow and numpy. Run every command from the repo root.

## Generate candidates

```bash
python3 tools/gradients/generate_gradients.py \
  --colors "#FF5A1F,#FFC400,#7B2FF7" \
  --count 8 --seed 7 \
  --out memory/gradients/candidates/
```

Writes `grad_001.json` + `grad_001.png` (and so on) with your palette only. The
base is derived dark and slightly tinted; layout and dominant color are seeded,
the glow is derived from the icon's layers, and the grain lives in the PNG only. Each PNG embeds its full preset in a text chunk, so the PNG alone is
enough to apply it. New runs continue after the highest `grad_###` already in
the folder instead of overwriting it. Without `--seed` the run picks one and
prints it.

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

Refresh derived fields after changing a generator rule:

```bash
# Re-normalizes every preset in assets/icon/presets.json (the glow is
# re-derived), rewrites the registry and lib/shared/design/gradient_presets.dart.
# Icon assets and flutter_launcher_icons.yaml stay untouched.
python3 tools/gradients/apply_gradient.py --refresh
```

Preview the Home/Me glow without an emulator:

```bash
# Writes memory/gradients/previews/<id>_home.png. The renderer mirrors what
# PresetGlow paints (stretched radials + the GLOW_FADE mask); check a glow change
# here before touching Flutter.
python3 tools/gradients/preview_home.py assets/icon/presets/neon-dusk/preset.json
```

Run the Python unit tests (the derived `glow` rules):

```bash
python3 -m unittest discover -s tools/gradients -p "test_*.py"
```

`--set-active` rewrites `flutter_launcher_icons.yaml` to the preset's legacy,
adaptive-background, foreground and monochrome files, and runs
`dart run flutter_launcher_icons`. The Android manifest is not touched.

Each preset carries its own `icon.foreground` and `icon.monochrome`; the tool
renders the legacy icon with that foreground. A preset whose icon is hand-made
sets `"hand_made": true` in its `icon` block: the tool validates the four files,
skips rendering and leaves them untouched, but still registers the preset and
updates the launcher config when it is active.

## Where things land

| Path | What | Git |
| --- | --- | --- |
| `memory/gradients/candidates/` | generator output | ignored |
| `memory/gradients/previews/` | `preview_home.py` output | ignored |
| `assets/icon/presets.json` | registry: every applied preset + `active` | tracked |
| `assets/icon/presets/<name>/preset.json` | the applied preset as given | tracked |
| `assets/icon/presets/<name>/icon_legacy_1024.png` | legacy icon, rounded corners | tracked |
| `assets/icon/presets/<name>/icon_adaptive_background.png` | 432 px adaptive background | tracked |
| `lib/shared/design/gradient_presets.dart` | generated Dart data | tracked, never edited |

The script also checks the existing foreground against Android's 66dp safe
circle and warns without resizing it. Applying the same name again updates it in
place and rewrites identical bytes, so the flow is idempotent.

In the app, read `AppGradientPresets.active` (or the
`activeGradientPresetProvider`) for `base` and `glow`. Home, Me's identity card
and the nav pill all paint `glow` through
`lib/shared/widgets/preset_glow.dart`: one `DecoratedBox` per glow layer, each
radial stretched horizontally by `width / height` (horizontal radius
`radius * width`, vertical `radius * height`). Only Home masks the stack with
`PresetGlow.fadeMask` (mirrors `GLOW_FADE`) so it blends into the page; the Me
card and the pill use `fadeOut: false`, clip the wash to their own radius and
keep it opaque: a left-to-right underlay of the layers' colors, pushed towards
black to match the page glow's darkness, fills the gaps where the radials reach
zero, so no black or surface color shows. The selected
tab's icon and label are light, not `onAccent`. The agent-facing checklist lives in
`.opencode/skills/gradient-preset/SKILL.md`.

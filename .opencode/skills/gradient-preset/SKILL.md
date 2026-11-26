---
name: gradient-preset
description: Apply a gradient preset from a generated PNG or JSON (app icon, adaptive icon, Home/Me glow and nav pill). Use when the user mentions gradient-preset and gives a preset path.
---

# Gradient preset

**When:** the user references `gradient-preset` and gives the path of a PNG or
JSON made by `tools/gradients/generate_gradients.py`. If they attach an image
without a path, ask for the file name; never guess which file they mean.

**Steps**

1. From the repo root run `python3 tools/gradients/apply_gradient.py <path> --set-active`.
   Add `--name <slug>` only if the user gave a name. The script reads the
   preset from the PNG metadata or the JSON, writes `assets/icon/presets/<name>/`,
   updates `assets/icon/presets.json`, regenerates the Dart file, points
   `flutter_launcher_icons.yaml` at the preset's legacy, background, foreground
   and monochrome files and runs the launcher tool.
2. When the generator changes a derived rule, run
   `python3 tools/gradients/apply_gradient.py --refresh` (no source): it
   re-normalizes every registered preset, re-derives the `glow`, and rewrites
   the registry and the Dart file without touching icon assets or the launcher
   config.
3. To judge the Home/Me glow before touching Flutter, run
   `python3 tools/gradients/preview_home.py <path>`: it writes
   `memory/gradients/previews/<id>_home.png` with the layers and fade that
   `PresetGlow` paints. Tuning lives in the `GLOW_*` constants of
   `gradient_preset.py`, nowhere else.
4. Run the AGENTS.md Verify steps with `~/flutter/bin` on PATH:
   `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.
   Run `python3 -m unittest discover -s tools/gradients -p "test_*.py"` too.
5. Update `memory/`: mark the task done, remove resolved items, add one line to
   `SESSION-LOG.md`.
6. Report in a short summary: preset id, files changed, launcher icon result and
   the Verify result.

**Rules**

- Never edit `lib/shared/design/gradient_presets.dart` or
  `assets/icon/presets.json` by hand; both are generated.
- The hand-made icon lives in `assets/icon/presets/default/` (colored four-bar
  mark on flat `#111114`). A preset can reference it with `"hand_made": true`
  and then only supplies the glow: never re-render or move that icon, and never
  point `flutter_launcher_icons.yaml` back at a generated foreground for it.
  Rendered presets (for example `cpunk`) use the shared all-white
  `assets/icon/ic_launcher_foreground.*`; `assets/icon/icon.svg` stays colored
  and `ic_launcher_monochrome.*` is the themed mark.
- `glow` is derived from the icon's own `layers` by `derive_glow` in
  `gradient_preset.py`: one glow layer per icon layer, same colors and stops,
  re-aimed at a wide box. Never randomize or hand-edit it; old files' `home`
  and `pill` keys are ignored. The `GLOW_*` constants there are the tuning
  knobs, including `GLOW_FADE`, which the Dart `PresetGlow.fadeMask` mirrors;
  change both together.
- Home, the Me identity card and the nav pill paint `glow` through
  `lib/shared/widgets/preset_glow.dart`: a stretched `RadialGradient` per layer.
  Only Home sets `fadeOut` (default true), so its wash blends into the page at
  the bottom; the card and the pill pass `fadeOut: false`, clip the wash to
  their own radius and keep it opaque: a left-to-right underlay of the layers'
  own colors, pushed towards black (`_Underlay._dim`) to match the page glow's
  darkness, fills the gaps where the radials reach zero, so no background
  shows through and the three surfaces share one palette. Do not add another
  glow, clip it to a header row, or edit the generated Dart for it. The Home
  glow box is taller than the content so the fade can reach zero. The selected
  tab's icon and label are light (`AppColors.textPrimary`), never `onAccent`,
  so they stay readable on the wash.
- Never pick or infer a preset visually. A PNG without metadata is an error:
  ask for the matching `.json` or use `--from-image`, do not guess.
- Ask nothing else. Only ask for a name if none was given and the candidate id
  is clearly a bad app name.
- The preset is Flutter math: `center` is an `Alignment` (-1..1), `radius` is a
  fraction of the shortest side, stops have 0..1 positions. Python must match
  Flutter; never tweak values by eye.

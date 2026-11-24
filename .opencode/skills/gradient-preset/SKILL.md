---
name: gradient-preset
description: Apply a gradient preset from a generated PNG or JSON (app icon, adaptive icon, Home and nav pill). Use when the user mentions gradient-preset and gives a preset path.
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
   `flutter_launcher_icons.yaml` at the preset and runs the launcher tool.
2. Run the AGENTS.md Verify steps with `~/flutter/bin` on PATH:
   `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.
3. Update `memory/`: mark the task done, remove resolved items, add one line to
   `SESSION-LOG.md`.
4. Report in a short summary: preset id, files changed, launcher icon result and
   the Verify result.

**Rules**

- Never edit `lib/shared/design/gradient_presets.dart` or
  `assets/icon/presets.json` by hand; both are generated.
- Never pick or infer a preset visually. A PNG without metadata is an error:
  ask for the matching `.json` or use `--from-image`, do not guess.
- Ask nothing else. Only ask for a name if none was given and the candidate id
  is clearly a bad app name.
- The preset is Flutter math: `center` is an `Alignment` (-1..1), `radius` is a
  fraction of the shortest side, stops have 0..1 positions. Python must match
  Flutter; never tweak values by eye.

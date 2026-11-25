# Alloy

Open source, local-first music player for Android and Linux, built with Flutter.

Alloy plays the music you already own: pick one or more folders, scan them, and
the library lives in a local SQLite database. Dark, minimal UI with gradient
accents, one identity on every platform.

## Status

Early development, but usable end to end on Android and Linux: pick a folder,
scan it, browse the library and play. The product definition is in
[`docs/spec.md`](docs/spec.md); what is still missing is listed under Features.

## Features

- **Local library** — folder scan with tag reading, a Drift (SQLite) catalog,
  embedded cover extraction with a disk cache, live scan progress and seven
  sort orders (title, date added, album, artist, duration).
- **Playback** — just_audio + audio_service on Android (notification and media
  session); media_kit + MPRIS on Linux. Play, pause, seek, next/previous,
  shuffle and three repeat modes.
- **Player** — mini-player over the navigation bar and a now-playing panel that
  expands from it with a tap or a drag: cover, waveform seek bar, queue
  controls and a gradient derived from the cover's dominant color.
- **Adaptive shell** — bottom navigation when compact, sidebar when wide; the
  panel expands inside the shell and settles drags with a spring.
- **Home and Discover** — recently added tracks, albums, generated mixes,
  library statistics, and a card deck that deals the library's own tracks. Most
  played, the activity chart and streaks are placeholder data until play
  history is recorded.
- **Personalization** — accent color, icon pack, language (English, Spanish)
  and gradient presets generated in code from one JSON preset.
- **Not built yet** — favorites, lyrics and metadata enrichment; the UI marks
  them as coming soon or TBD.

## Requirements

- Flutter 3.50.x / Dart 3.14 (the toolchain used by the project)
- Android SDK for Android builds
- GTK 3 development headers, CMake, Ninja and Clang for Linux builds
- Python 3 with Pillow and numpy, only for the gradient tooling

## Setup

```sh
flutter pub get
dart run build_runner build
flutter gen-l10n
```

## Commands

```sh
flutter run -d linux                # run on Linux
flutter run -d <android-device-id>  # run on Android
flutter test                        # unit and widget tests
flutter test --coverage             # tests plus coverage/lcov.info
flutter analyze                     # static analysis
dart format --set-exit-if-changed .
flutter build linux --release       # release bundle
flutter build apk --release         # release APK
```

Codegen (freezed, drift, riverpod) after changing annotated code:

```sh
dart run build_runner build
dart run build_runner watch       # keep regenerating while editing
```

Generated files are gitignored: run the generator after cloning and in CI.
After editing `.arb` files, run `flutter gen-l10n` (its output is committed).

## Tooling

Gradient presets (app icon, Home/Me glow, nav pill) are generated from JSON by
the Python scripts in `tools/gradients/`; see
[`tools/gradients/README.md`](tools/gradients/README.md). `tool/visual/` holds
the emulator capture and hot-reload scripts used for visual review.

## Architecture

Pragmatic Clean Architecture, feature-first:

- `lib/app/` — bootstrap, router, theme, shell
- `lib/core/` — shared primitives (`Result`, `Failure`, logger, platform info)
- `lib/shared/` — design tokens, gradients, reusable widgets
- `lib/features/<feature>/{domain,data,presentation}` — one folder per feature
  (`home`, `discover`, `library`, `player`, `settings`, `favorites`)

Layers point inward: `presentation -> domain <- data`. A feature may import
another feature's `domain` only. `domain` is pure Dart. Platform differences
live behind domain interfaces and are wired once in `app/bootstrap`. The rules
are documented in [`AGENTS.md`](AGENTS.md) and enforced by
`test/architecture_test.dart`.

Tests use fakes (playback engine, folder picker, permissions, file tags) and
in-memory SQLite; they never touch real files, network or time.

## Continuous integration

[`.github/workflows/ci.yaml`](.github/workflows/ci.yaml) runs on pushes and pull
requests to `main`:

- format check, `flutter analyze` and `flutter test` (which includes the
  architecture rules)
- release builds for Linux and the Android APK, uploaded as artifacts

Generated code is not committed, so every job runs `build_runner` first.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

GPL-3.0. See [`LICENSE`](LICENSE).

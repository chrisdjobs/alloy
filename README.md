# Bars

Open source, local-first music player for Android and Linux, built with Flutter.

Bars plays the music you already own: pick one or more folders, scan them, and
the library lives in a local SQLite database. Dark, minimal UI with gradient
accents, one identity on every platform.

## Status

Early development. The shell, design system, playback engine (Android and
Linux) and the local library (folder scan, SQLite, browse and shuffle all) are
in place; cover art and the now-playing screen follow. The product definition
is in [`docs/spec.md`](docs/spec.md).

## Requirements

- Flutter 3.50.x / Dart 3.14 (the toolchain used by the project)
- Android SDK for Android builds
- GTK 3 development headers and CMake for Linux builds

## Setup

```sh
flutter pub get
dart run build_runner build
flutter gen-l10n
```

## Commands

```sh
flutter run -d linux              # run on Linux
flutter run -d <android-device-id>  # run on Android
flutter test                      # unit and widget tests
flutter test --coverage           # tests plus coverage/lcov.info
flutter analyze                   # static analysis
dart format --set-exit-if-changed .
```

Codegen (freezed, drift, riverpod) after changing annotated code:

```sh
dart run build_runner build
dart run build_runner watch       # keep regenerating while editing
```

Generated files are gitignored: run the generator after cloning and in CI.
After editing `.arb` files, run `flutter gen-l10n` (its output is committed).

## Architecture

Pragmatic Clean Architecture, feature-first:

- `lib/app/` — bootstrap, router, theme, shell
- `lib/core/` — shared primitives (`Result`, `Failure`, logger, platform info)
- `lib/shared/` — design tokens, gradients, reusable widgets
- `lib/features/<feature>/{domain,data,presentation}` — one folder per feature

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

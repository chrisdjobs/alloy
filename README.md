# Bars

Open source, local-first music player for Android and Linux, built with Flutter.

Bars plays the music you already own: pick one or more folders, scan them, and
the library lives in a local SQLite database. Dark, minimal UI with gradient
accents, one identity on every platform.

## Status

Scaffold in progress. The shell, design system and playback engine (Android and
Linux) are in place; the local library follows. The product definition is in
[`docs/spec.md`](docs/spec.md).

## Requirements

- Flutter 3.50.x / Dart 3.14 (the toolchain used by the project)
- Android SDK for Android builds
- GTK 3 development headers and CMake for Linux builds

## Setup

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

## Commands

```sh
flutter run -d linux              # run on Linux
flutter run -d <android-device-id>  # run on Android
flutter test                      # unit and widget tests
flutter analyze                   # static analysis
dart format --set-exit-if-changed .
```

Codegen (freezed, drift, riverpod) after changing annotated code:

```sh
dart run build_runner build --delete-conflicting-outputs
```

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

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

GPL-3.0. See [`LICENSE`](LICENSE).

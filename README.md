# bars

Open source, local-first music player built with Flutter. It plays the music you
already own, stored on your device. Dark, minimal UI with gradient accents.
Android and Linux are first-class; the design leaves room for other music
sources (Jellyfin first) without rewriting the library layer.

Working name: `bars` (a codename, it may still change). App id:
`com.dynamjobs.bars`.

## Status

Early scaffold. The app does not play music yet; the skeleton, tooling and
architecture rules are in place and features are added one at a time.

## Requirements

- Flutter 3.44+ (Dart 3.12+), stable channel
- Android: Android SDK and a device or emulator
- Linux: GTK 3 development headers and CMake

## Setup

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

## Commands

```sh
flutter run -d linux
flutter run -d <android-device-id>
flutter test
flutter analyze
dart run import_lint
dart format --set-exit-if-changed .
```

Codegen (freezed, drift, riverpod) after changing annotated code:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

Pragmatic Clean Architecture, feature-first, with domain/data/presentation
layers inside each feature. The rules are in [`AGENTS.md`](AGENTS.md) and the
product definition is in [`docs/spec.md`](docs/spec.md). Import rules are
enforced by `import_lint` (see `analysis_options.yaml`).

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

GPL-3.0. See [`LICENSE`](LICENSE).

# Contributing to Bars

Thanks for helping. Bars is a small, opinionated Flutter project; reading this
file before the first pull request saves review time.

## Before you start

- Read [`docs/spec.md`](docs/spec.md) (what the project is) and
  [`AGENTS.md`](AGENTS.md) (architecture rules and conventions).
- Android and Linux are first-class. iOS, macOS and Windows are not tested yet:
  do not block them, but do not spend time on them either.
- Out of scope: Jellyfin and other remote sources, downloads, metadata
  enrichment, online lyrics, playlists, favorites, search, equalizer, sync and
  accounts. Do not add them without an issue that changes the spec first.

## Workflow

1. Open or pick an issue that describes the change.
2. Create a branch from `main`.
3. Keep the change small and focused; no drive-by refactors.
4. Run the checks locally (see below) before pushing.
5. Open a pull request using Conventional Commits for the title
   (`feat(player): ...`, `fix(library): ...`, `chore: ...`).

## Commands

```sh
flutter pub get                          # dependencies
dart run build_runner build              # generated code
dart run build_runner watch              # regenerate while editing
flutter gen-l10n                         # after .arb edits
dart format --set-exit-if-changed .      # formatting
flutter analyze                          # analyzer
flutter test                             # tests (includes architecture rules)
flutter test --coverage                  # tests plus coverage/lcov.info
```

Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are never edited by
hand; they are gitignored, so run the generator after cloning and let CI
regenerate them.

## Pull request checklist

- [ ] `dart format --set-exit-if-changed .` is clean
- [ ] `flutter analyze` reports no issues
- [ ] `flutter test` passes
- [ ] New behavior has a test (unit test for logic, `testWidgets` for UI)
- [ ] Architecture rules hold (`test/architecture_test.dart` passes)
- [ ] User-facing strings go through l10n (`en` and `es`)
- [ ] Conventional Commits message
- [ ] The CI workflow is green (format, analyze, tests, Linux and Android builds)

## Architecture rules (short version)

- Layers: `presentation -> domain <- data`. Presentation never imports `data`.
- A feature imports another feature's `domain` only.
- `domain` is pure Dart: no Flutter, Drift or platform imports.
- Platform differences live behind domain interfaces and are wired in
  `app/bootstrap` only.
- Every music source implements `MusicSource`; library code never assumes a
  local file path.
- Domain returns `Result<T>` with sealed `Failure` types, never throws across
  layer boundaries.
- State management is Riverpod with code generation. No second approach.
- No `print`; use the project logger.
- Colors, spacing, radii and gradients come from `shared/design`.

The full list is in [`AGENTS.md`](AGENTS.md).

## License

By contributing you agree that your contributions are licensed under
GPL-3.0 (see [`LICENSE`](LICENSE)).

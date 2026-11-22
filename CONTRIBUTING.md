# Contributing to bars

Thanks for helping. Keep changes small and focused, and follow the project
rules in [`AGENTS.md`](AGENTS.md).

## Setup

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

## Before you open a PR

Run the same checks as CI, in this order:

```sh
dart format --set-exit-if-changed .
flutter analyze
dart run import_lint
flutter test
```

If you touched annotated code (freezed, drift, riverpod_generator), run
`dart run build_runner build --delete-conflicting-outputs` first. If you
touched `.arb` files, run `flutter gen-l10n`.

## Architecture rules (summary)

- `presentation` -> `domain` <- `data`; presentation never imports data.
- A feature may import another feature's `domain` only.
- `domain` is pure Dart: no Flutter, Drift or platform imports.
- Platform differences live behind domain interfaces and are wired only in
  `lib/app/bootstrap.dart`.
- No hand-written singletons or static mutable state; services are providers.
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are never edited
  by hand.
- User-facing strings go through l10n (English and Spanish).

The full list is in [`AGENTS.md`](AGENTS.md).

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `docs:`, `test:`, `chore:`, `refactor:`.

## Pull request checklist

- [ ] `dart format --set-exit-if-changed .` passes
- [ ] `flutter analyze` passes
- [ ] `dart run import_lint` passes
- [ ] `flutter test` passes
- [ ] Codegen was re-run if annotated code changed
- [ ] New user-facing strings are in both `app_en.arb` and `app_es.arb`
- [ ] No out-of-scope features were added

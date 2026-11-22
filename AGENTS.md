# AGENTS.md — Flutter

Project spec: `docs/spec.md` (what the project is). Read it before planning or coding.

## Memory protocol (read first)
- Start of session: read `memory/README.md`, then `memory/CURRENT.md`. Open other memory files only if the task needs them.
- End of session: overwrite `memory/CURRENT.md` and prepend an entry to `memory/SESSION-LOG.md` (max 8 lines).
- Decisions go in `memory/decisions/`, plans in `memory/plans/`, bugs in `memory/BUGS.md`. Respect the size caps in `memory/README.md`.
- Never store secrets or code dumps.

## Verify (run all, in order, before calling any step done)
1. `dart format --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`

If the step touches annotated code (freezed, json_serializable, riverpod_generator, drift...): run `dart run build_runner build --delete-conflicting-outputs` first.
If the step touches `.arb` files: run `flutter gen-l10n`.
Do not run `flutter run` or release builds (long-running). Ask the user.

## Environment / network
- Never use download mirrors (no `FLUTTER_STORAGE_BASE_URL`, no pub mirrors). If pub.dev or Flutter's artifact host is blocked, stop and ask the user; they fix network access with a VPN.
- Toolchain: Flutter 3.50.1 / Dart 3.14, installed at `~/flutter` (not on `PATH`). Add `~/flutter/bin` per command.

## Project-specific
- State management: Riverpod with code generation (`@riverpod`). `Notifier` / `AsyncNotifier` = ViewModel.
- Routing: go_router.
- Backend / data layer: none, local-first. Drift (SQLite) for the library. Music comes through `MusicSource` implementations (local now, Jellyfin later).
- Min SDK / platforms: Android and Linux are first-class (must build and run). iOS, macOS and Windows: do not block them, do not test them. Min SDK is set at scaffold time from the audio packages' requirements.
- Audio: `PlaybackEngine` interface. Android = just_audio + audio_service. Linux = media_kit backend + MPRIS.
- App id: `com.dynamjobs.bars` (project name `bars`).

## Structure
Pragmatic Clean Architecture: feature-first folders, with domain/data/presentation layers inside each feature.
- `lib/app/`: bootstrap, router, theme, shell
- `lib/core/`: shared code (Result, Failure, logger, platform info, utils)
- `lib/shared/`: design tokens, reusable widgets
- `lib/features/<feature>/{data,domain,presentation}`
- `test/` mirrors `lib/`

## Architecture rules
1. `domain` is pure Dart. No Flutter, Drift or platform imports.
2. `presentation` -> `domain` <- `data`. Presentation never imports `data`.
3. A feature may import another feature's `domain` only. Never its `data` or `presentation`.
4. Use cases only for real logic. Do not wrap a repository call in a class that adds nothing.
5. Platform differences live behind domain interfaces and are wired in one place (`app/bootstrap`). No `Platform.isX` outside `core/platform` and bootstrap.
6. Every music source (local, Jellyfin, ...) implements `MusicSource`. Library code never assumes local files.

## Conventions
- Null safety always. Prefer `final`, immutable models (freezed), `const` constructors.
- No business logic in widgets. Widgets render state and forward events. No I/O in widgets.
- Do not introduce a second state-management approach. Use the one in the spec.
- Single-instance services (DB, engine, sources) are providers. No hand-written singletons, no static mutable state.
- Domain returns `Result<T>` with sealed `Failure` types. Do not throw across layer boundaries.
- Handle loading, error and data for every `AsyncValue`.
- Add packages with `flutter pub add`, never by hand-editing pubspec, and only if the plan says so. Prefer maintained, null-safe, multiplatform packages.
- Check every third-party API with context7 before using it. Never write library calls from memory.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`).
- No `print`; use the project logger.
- After an `await`, check `mounted` before using `BuildContext`. Dispose controllers, streams and focus nodes.
- User-facing strings go through l10n (arb, en + es), not hardcoded.
- Colors, spacing, radii and gradients come from `shared/design`. No magic numbers in widgets.
- Small files (aim for under 300 lines if possible). Comments explain why, never what. No dead or commented-out code.

## UI
One visual identity on every platform: dark, minimal, gradients generated in code (no gradient PNGs).
Layout adapts to width: bottom navigation when compact, sidebar when wide.
No Cupertino theme. On iOS, only platform behaviors (scroll physics, back swipe).
Assets that are not designed yet (logo, intro animation, illustrations, custom icons) use the `TbdPlaceholder` widget showing `TBD`. Do not invent brand assets. Functional icons come from `shared/design/app_icons.dart`.
If `memory/references/` exists, UI tasks start with its `INDEX.md` (and `design-notes.md`). Open screenshots only when needed, and only the relevant ones. Never copy names, logos, icons or assets from them.

## Tests
- Unit tests for logic, widget tests (`testWidgets`) for UI behavior. Name: `<file>_test.dart`.
- Prefer fakes over mocks. A `FakePlaybackEngine` for player tests, in-memory Drift for repositories. No real network or real time.
- Bug fixes get a regression test when feasible.

## Don't
- Do not implement features that were not requested. Do not refactor outside the task.
- Do not add Jellyfin, downloads, or metadata and online-lyrics services unless asked.
- Do not build anything related to Sync, even if it appears in the reference screenshots.
- Do not commit unless asked. When asked, use Conventional Commits.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)

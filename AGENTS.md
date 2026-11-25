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

## Environment / network
- Never use download mirrors (no `FLUTTER_STORAGE_BASE_URL`, no pub mirrors). If pub.dev or Flutter's artifact host is blocked, stop and ask the user; they fix network access with a VPN.
- Visual work is the exception to the long-running rule: the agent may boot the `Pixel_10_Pro` AVD (`flutter emulators --launch Pixel_10_Pro`) and run `flutter run -d emulator-5554 --pid-file /tmp/opencode/alloy.pid --no-devtools` in the background; reload with `kill -USR1 $(cat /tmp/opencode/alloy.pid)` (`-USR2` = hot restart) and capture with `tool/visual/shot.sh`. Stop the run when the work is over; never leave it alive. Only when the user requests it or is part of the plan to open the emulator and visual polish with this method.
- Still ask before release builds and before running anything on the physical phone.

## Project-specific
- State management: Riverpod with code generation (`@riverpod`). `Notifier` / `AsyncNotifier` = ViewModel.
- Routing: go_router.
- Backend / data layer: none, local-first. Drift (SQLite) for the library. Music comes through `MusicSource` implementations (local now, Jellyfin later).
- Min SDK / platforms: Android and Linux are first-class (must build and run). iOS, macOS and Windows: do not block them, do not test them. Min SDK is set at scaffold time from the audio packages' requirements.
- Audio: `PlaybackEngine` interface. Android = just_audio + audio_service. Linux = media_kit backend + MPRIS.
- App id: `com.dynamjobs.alloy` (project name `alloy`).

## Structure
Pragmatic Clean Architecture: feature-first folders, with domain/data/presentation layers inside each feature.
- `lib/app/`: bootstrap, router, theme, shell
- `lib/core/`: shared code (Result, Failure, logger, platform info, utils)
- `lib/shared/`: design tokens, reusable widgets
- `lib/features/<feature>/{data,domain,presentation}`
- `test/` mirrors `lib/`
- `tool/visual/`: capture and reload scripts for visual review, not app code

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
The emulator is the visual source of truth. Every visual change is proven with a before/after capture compared against `memory/references/`, not from memory.
Visual polish targets Android on the emulator in portrait. Linux and the wide (sidebar) layout wait until the user opens them.

## Tests
- Tests are written on request only. A phase, a feature or a bug fix does not come with tests; the user asks for them explicitly, and the `test` agent writes them. The build agent never adds test files, cases or fakes.
- `flutter test` stays in Verify as a regression gate. If a layout or visual change breaks an existing assertion, update or remove that assertion; never add cases to make a step look defended.
- Prefer fakes over mocks. A `FakePlaybackEngine` for player tests, in-memory Drift for repositories. No real network or real time.

## Don't
- Do not write tests unless asked.
- Do not implement features that were not requested. Do not refactor outside the task.
- Do not add Jellyfin, downloads, or metadata and online-lyrics services unless asked.
- Do not build anything related to Sync, even if it appears in the reference screenshots.
- Do not commit unless asked. When asked, use Conventional Commits.

## Lessons (add a rule here every time the agent fails the same way twice)
- (empty)

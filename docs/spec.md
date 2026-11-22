# Bars — Spec

> Working name (a codename, it may still change). Draft built from the decisions taken so far: edit anything that is not right.

## Goal
Open source, local-first music player in Flutter: dark, minimal UI with gradient accents. It plays the music a person already owns, stored on their device. Built for people who keep their own library, Android and Linux first. Designed so other sources (Jellyfin first) can be added later without rewriting the library layer.

## Scope v1
- Choose music folder(s), scan them, read tags, store the library in SQLite
- Browse the library (tracks first, then albums and artists)
- Playback queue: play, pause, seek, next, previous
- Background playback and OS media controls (Android notification and media session, Linux MPRIS and media keys)
- Mini-player and full now-playing screen
- Show lyrics embedded in the file tags
- Adaptive layout: bottom navigation when compact, sidebar when wide
- English and Spanish

## Out of scope (for now)
- Jellyfin and any other remote source
- Music downloads
- Metadata enrichment (`MetadataProvider`: MusicBrainz, Cover Art Archive), planned for later
- Playlists, favorites, search, equalizer
- Online lyrics (`LyricsProvider`: LRCLIB or similar), planned for later
- Artwork-based dynamic gradients
- Accounts and cloud sync
- Sync of any kind (cross-device linking): ignored completely, including in the reference screenshots
- Discover / remote catalogs, Android home-screen widget, statistics, profile and gamification (they appear in the references, not planned)
- iOS, macOS and Windows runners (later, with build-only CI jobs to keep them compiling)

## Technical decisions (only what is already decided; the planner asks about the rest)
- Stack / framework + version: Flutter, latest stable at project start
- State management / architecture: pragmatic Clean Architecture (domain/data/presentation layers per feature), organized feature-first; Riverpod with code generation; freezed
- Backend / data: none (local-first); Drift (SQLite) for the library
- Auth: none
- Hosting / distribution: GitHub releases for now; stores decided later
- License: GPL-3.0 by default (revisit before the first public release; GPLv3 conflicts with Apple App Store terms)
- Routing: go_router
- Localization: gen-l10n (en, es)
- App id: `com.dynamjobs.bars`, project name `bars`

Domain contracts
- `MusicSource`: lists/scans tracks from a source and resolves a playable `Uri` for a track. First implementation: `LocalMusicSource`. Jellyfin comes later.
- `Track`: carries `sourceId` and `sourceItemId`. Never assume a track is a file path.
- `PlaybackEngine`: load queue, play, pause, seek, stop, skip. Exposes streams for state, position and current track.
- `LibraryRepository`: library as a stream; triggers a scan.
- `LyricsProvider` (after the scaffold): returns lyrics for a track. First implementation reads lyrics embedded in the file tags; online providers (LRCLIB or similar) come later.

Audio per platform
- Android: just_audio + audio_service (background playback, notification, media session).
- Linux: media_kit backend (just_audio_media_kit) + MPRIS.
- The engine is selected by provider override in `app/bootstrap`. No platform checks elsewhere.

UI
- One visual identity on every platform: dark, minimal, gradients generated in code (no gradient PNGs).
- Material 3 with custom tokens. No Cupertino theme. On iOS, only platform behaviors (scroll physics, back swipe).
- Assets not designed yet (logo, intro animation, illustrations, custom icons) are `TBD` placeholders.
- Visual references live in `memory/references/` (screenshots plus design notes). They guide structure and feel only; no names, icons or assets are copied.

## Data model (rough)
- `Source`: id, type (local, later jellyfin), config
- `Track`: id, sourceId, sourceItemId, title, artist, album, trackNumber, durationMs, artwork reference
- `Album`, `Artist`: derived from tags, linked to tracks
- Lyrics are read on demand through `LyricsProvider`, not stored in `Track`
- Later: `Playlist`, favorites

## Constraints
- Platforms: Android and Linux are first-class (must build and run). iOS, macOS and Windows are not blocked and not tested: no runners yet, avoid unguarded `dart:io` assumptions and hardcoded Android/Linux paths outside platform adapters.
- Linux desktop follows Linux conventions: MPRIS, media keys, sidebar navigation.
- macOS sandbox needs file-access entitlements: keep folder access inside the source adapter.
- Offline-first; no network needed for v1.
- A library of 10k+ tracks scrolls smoothly; scanning runs off the UI thread.
- Easy for first-time contributors: clear layers, enforced import rules, CI.
- Solo developer, free-tier tooling.

## Done criteria
- On Android and Linux: pick a folder, see the library, play a track, control it from the app and from the OS media controls.
- The Verify steps in `AGENTS.md` pass and CI is green.
- README and CONTRIBUTING explain setup, commands and architecture.
- Nothing from "Out of scope" has been built.

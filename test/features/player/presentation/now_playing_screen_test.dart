import 'package:bars/app/theme.dart';
import 'package:bars/core/artwork/artwork_providers.dart';
import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/domain/playback_state.dart';
import 'package:bars/features/player/presentation/now_playing_screen.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/features/player/presentation/widgets/seek_bar.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/cover_colors.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide RepeatMode;

import '../../../fakes/cover_test_image.dart';
import '../../../fakes/fake_artwork_repository.dart';
import '../../../fakes/fake_playback_engine.dart';

void main() {
  late FakePlaybackEngine engine;

  setUp(() => engine = FakePlaybackEngine());
  tearDown(() => engine.dispose());

  testWidgets('shows album, title, artist and the technical line', (
    tester,
  ) async {
    await _pump(tester, engine);
    await _load(tester, engine);

    expect(find.text('Night'), findsOneWidget);
    expect(find.text('Aurora'), findsOneWidget);
    expect(find.text('Nina'), findsOneWidget);
    expect(find.text('44.1 kHz · 320 kbps · MP3 · 1 of 3'), findsOneWidget);
    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('3:00'), findsOneWidget);
  });

  testWidgets('the seek bar seeks inside the track', (tester) async {
    await _pump(tester, engine);
    await _load(tester, engine);

    final bar = tester.getRect(find.byType(SeekBar));
    await tester.tapAt(bar.center);
    await tester.pump();

    expect(engine.seeks, hasLength(1));
    expect(
      engine.seeks.single.inMilliseconds,
      closeTo(const Duration(minutes: 1, seconds: 30).inMilliseconds, 500),
    );
  });

  testWidgets('shuffle, previous and next reach the engine', (tester) async {
    await _pump(tester, engine);
    await _load(tester, engine);

    await tester.tap(find.byTooltip('Shuffle'));
    await tester.tap(find.byTooltip('Previous'));
    await tester.tap(find.byTooltip('Next'));
    await tester.pump();

    expect(engine.shuffles, [true]);
    expect(engine.skipPreviousCalls, 1);
    expect(engine.skipNextCalls, 1);
  });

  testWidgets('play/pause uses the round button', (tester) async {
    await _pump(tester, engine);
    await _load(tester, engine);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(engine.playCalls, 1);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(engine.pauseCalls, 1);
  });

  testWidgets('repeat cycles through all three modes', (tester) async {
    await _pump(tester, engine);
    await _load(tester, engine);

    await tester.tap(find.byTooltip('Repeat off'));
    await tester.pump();
    await tester.tap(find.byTooltip('Repeat'));
    await tester.pump();
    await tester.tap(find.byTooltip('Repeat one'));
    await tester.pump();

    expect(engine.repeatModes, [
      RepeatMode.all,
      RepeatMode.one,
      RepeatMode.off,
    ]);
  });

  testWidgets('the overflow menu stops playback', (tester) async {
    await _pump(tester, engine);
    await _load(tester, engine);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop playback'));
    await tester.pumpAndSettle();

    expect(engine.stopCalls, 1);
  });

  testWidgets('shows the cover without a live blur filter', (tester) async {
    final artwork = FakeArtworkRepository()
      ..visuals[const ArtworkRef('cover-hash')] = {
        ArtworkSize.large: ArtworkVisual(
          cover: testCoverBytes,
          backdrop: testCoverBytes,
          backdropColorArgb: CoverColors.backdropFor(0xFF305070),
        ),
      };
    await _pump(tester, engine, artwork: artwork);
    await _load(tester, engine, artworkRef: const ArtworkRef('cover-hash'));

    expect(find.byType(ArtworkImage), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('centers the content on wide layouts without stretching', (
    tester,
  ) async {
    await _pump(tester, engine, size: const Size(1200, 900));
    await _load(tester, engine);

    final content = tester.getSize(
      find.byKey(const ValueKey('now-playing-content')),
    );
    expect(content.width, 520);
  });

  testWidgets('the chevron closes the screen', (tester) async {
    await _pumpRouted(tester, engine);
    await _openNowPlaying(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(NowPlayingScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a downward swipe closes the screen', (tester) async {
    await _pumpRouted(tester, engine);
    await _openNowPlaying(tester);

    await tester.drag(find.byType(NowPlayingScreen), const Offset(0, 160));
    await tester.pumpAndSettle();

    expect(find.byType(NowPlayingScreen), findsNothing);
  });
}

Future<void> _load(
  WidgetTester tester,
  FakePlaybackEngine engine, {
  int index = 0,
  ArtworkRef? artworkRef,
}) async {
  await engine.loadQueue([
    _track('Aurora', artworkRef: artworkRef),
    _track('Second'),
    _track('Third'),
  ], initialIndex: index);
  await tester.pumpAndSettle();
}

Track _track(String title, {ArtworkRef? artworkRef}) {
  return Track(
    id: 'local:/music/$title.mp3',
    sourceId: 'local',
    sourceItemId: '/music/$title.mp3',
    title: title,
    artist: 'Nina',
    album: 'Night',
    durationMs: 180000,
    sampleRateHz: 44100,
    bitrateKbps: 320,
    format: 'MP3',
    artworkRef: artworkRef,
  );
}

Future<void> _pump(
  WidgetTester tester,
  FakePlaybackEngine engine, {
  FakeArtworkRepository? artwork,
  Size size = const Size(420, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playbackEngineProvider.overrideWithValue(engine),
        artworkRepositoryProvider.overrideWithValue(
          artwork ?? FakeArtworkRepository(),
        ),
      ],
      child: _app(const NowPlayingScreen()),
    ),
  );
  await tester.pump();
}

Future<void> _pumpRouted(WidgetTester tester, FakePlaybackEngine engine) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playbackEngineProvider.overrideWithValue(engine),
        artworkRepositoryProvider.overrideWithValue(FakeArtworkRepository()),
      ],
      child: _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const NowPlayingScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _openNowPlaying(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.byType(NowPlayingScreen), findsOneWidget);
}

Widget _app(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    theme: AppTheme.dark(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

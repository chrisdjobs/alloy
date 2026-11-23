import 'package:bars/app/theme.dart';
import 'package:bars/core/artwork/artwork_providers.dart';
import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/failure.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/presentation/mini_player.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:bars/shared/widgets/no_cover_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../fakes/fake_artwork_repository.dart';
import '../../../fakes/fake_playback_engine.dart';

void main() {
  late FakePlaybackEngine engine;

  setUp(() => engine = FakePlaybackEngine());
  tearDown(() => engine.dispose());

  testWidgets('stays hidden while nothing is loaded', (tester) async {
    await _pump(tester, engine);

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Track a'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows title and artist of the current track', (tester) async {
    await _pump(tester, engine);
    engine.emitTrack(_track());
    await tester.pumpAndSettle();

    expect(find.text('Track a'), findsOneWidget);
    expect(find.text('Artist'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(NoCoverTile), findsOneWidget);
  });

  testWidgets('renders the track cover through ArtworkImage', (tester) async {
    await _pump(tester, engine);
    engine.emitTrack(
      _track().copyWith(artworkRef: const ArtworkRef('cover-hash')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ArtworkImage), findsOneWidget);
  });

  testWidgets('custom artwork and backdrop slots are rendered', (tester) async {
    await _pump(
      tester,
      engine,
      leading: const Icon(Icons.album),
      backdrop: const ColoredBox(color: Colors.black),
    );
    engine.emitTrack(_track());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.album), findsOneWidget);
    expect(find.byType(NoCoverTile), findsNothing);
    expect(find.byType(ColoredBox), findsWidgets);
  });

  testWidgets('play/pause and next reach the engine', (tester) async {
    await _pump(tester, engine);
    engine.emitTrack(_track());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(engine.playCalls, 1);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();
    expect(engine.pauseCalls, 1);

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(engine.skipNextCalls, 1);
  });

  testWidgets('shows an error bar with a working retry', (tester) async {
    await _pump(tester, engine);
    engine.emitTrack(_track());
    await tester.pumpAndSettle();

    engine.nextFailure = const Failure.unknown(message: 'boom');
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsNothing);
    expect(find.text('Track a'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakePlaybackEngine engine, {
  Widget? leading,
  Widget? backdrop,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playbackEngineProvider.overrideWithValue(engine),
        artworkRepositoryProvider.overrideWithValue(FakeArtworkRepository()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.dark(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: MiniPlayer(leading: leading, backdrop: backdrop),
        ),
      ),
    ),
  );
  await tester.pump();
}

Track _track() {
  return const Track(
    id: 'a',
    sourceId: 'local',
    sourceItemId: '/music/a.mp3',
    title: 'Track a',
    artist: 'Artist',
    album: 'Album',
    durationMs: 180000,
  );
}

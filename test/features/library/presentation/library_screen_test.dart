import 'package:alloy/app/theme.dart';
import 'package:alloy/core/artwork/artwork_providers.dart';
import 'package:alloy/features/library/domain/music_source.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/library/presentation/library_notifier.dart';
import 'package:alloy/features/library/presentation/library_screen.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:alloy/shared/widgets/no_cover_tile.dart';
import 'package:alloy/shared/widgets/tbd_placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../fakes/fake_artwork_repository.dart';
import '../../../fakes/fake_library_repository.dart';

void main() {
  late FakeLibraryRepository repository;
  late List<(List<Track>, int)> played;
  late List<List<Track>> shuffled;

  setUp(() {
    repository = FakeLibraryRepository();
    played = [];
    shuffled = [];
  });

  tearDown(() => repository.dispose());

  testWidgets('shows a spinner while the library loads', (tester) async {
    repository.neverEmits = true;

    await _pump(tester, repository, played, shuffled);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an error card with retry', (tester) async {
    repository.initialError = StateError('database gone');

    await _pump(tester, repository, played, shuffled);
    await tester.runAsync(pumpEventQueue);
    await tester.pump();

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(LibraryScreen), findsOneWidget);
  });

  testWidgets('shows the empty state and scans a chosen folder', (
    tester,
  ) async {
    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    expect(find.byType(TbdPlaceholder), findsOneWidget);
    expect(find.text('No tracks found'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Choose folder'));
    await tester.pump();

    expect(repository.scanFolderCalls, 1);
  });

  testWidgets('renders tracks and shuffle all', (tester) async {
    repository.tracks = [_track('Alpha'), _track('Beta')];

    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    expect(find.text('SHUFFLE ALL'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.byType(ArtworkImage), findsNWidgets(2));
    expect(find.byType(NoCoverTile), findsNWidgets(2));
  });

  testWidgets('tapping a track forwards the queue and index', (tester) async {
    repository.tracks = [_track('Alpha'), _track('Beta')];

    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beta'));
    await tester.pump();

    expect(played, hasLength(1));
    expect(played.single.$2, 1);
    expect(played.single.$1, hasLength(2));
  });

  testWidgets('shuffle all forwards the whole library', (tester) async {
    repository.tracks = [_track('Alpha'), _track('Beta')];

    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    await tester.tap(find.text('SHUFFLE ALL'));
    await tester.pump();

    expect(shuffled, hasLength(1));
    expect(shuffled.single, hasLength(2));
  });

  testWidgets('the overflow menu plays the track', (tester) async {
    repository.tracks = [_track('Alpha')];

    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play').last);
    await tester.pumpAndSettle();

    expect(played, hasLength(1));
  });

  testWidgets('the header action rescans the last folder', (tester) async {
    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rescan library'));
    await tester.pump();

    expect(repository.triggerScanCalls, 1);
  });

  testWidgets('shows and hides scan progress', (tester) async {
    await _pump(tester, repository, played, shuffled);
    await tester.pumpAndSettle();

    repository.emitScanProgress(
      const ScanProgress(filesFound: 4, filesRead: 1),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Scanning'), findsOneWidget);

    repository.emitScanProgress(
      const ScanProgress(filesFound: 4, filesRead: 4, isComplete: true),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Scanning'), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeLibraryRepository repository,
  List<(List<Track>, int)> played,
  List<List<Track>> shuffled,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(repository),
        artworkRepositoryProvider.overrideWithValue(FakeArtworkRepository()),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LibraryScreen(
            onPlay: (tracks, index) => played.add((tracks, index)),
            onShuffleAll: shuffled.add,
          ),
        ),
      ),
    ),
  );
}

Track _track(String title) => Track(
  id: 'local:/music/$title.mp3',
  sourceId: 'local',
  sourceItemId: '/music/$title.mp3',
  title: title,
  artist: 'Artist',
);

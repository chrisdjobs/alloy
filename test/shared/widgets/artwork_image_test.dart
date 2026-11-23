import 'dart:convert';

import 'package:bars/core/artwork/artwork_providers.dart';
import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:bars/shared/widgets/no_cover_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../fakes/fake_artwork_repository.dart';

void main() {
  final cover = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGA'
    'hKmMIQAAAABJRU5ErkJggg==',
  );

  testWidgets('a null reference renders the no-cover tile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ArtworkImage(artworkRef: null)),
    );

    expect(find.byType(NoCoverTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the resolved cover', (tester) async {
    final repository = FakeArtworkRepository()
      ..visuals[const ArtworkRef('a')] = {
        ArtworkSize.small: ArtworkVisual(
          cover: cover,
          backdrop: cover,
          backdropColorArgb: 0xFF201810,
        ),
      };

    await _pump(tester, repository, const ArtworkRef('a'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(NoCoverTile), findsNothing);
    expect(repository.requests.single, (
      const ArtworkRef('a'),
      ArtworkSize.small,
    ));
  });

  testWidgets('large tiles request the large variant', (tester) async {
    final repository = FakeArtworkRepository();
    await _pump(tester, repository, const ArtworkRef('a'), size: 320);
    await tester.pump();

    expect(repository.requests.single.$2, ArtworkSize.large);
  });

  testWidgets('a missing cover falls back to the no-cover tile', (
    tester,
  ) async {
    final repository = FakeArtworkRepository();

    await _pump(tester, repository, const ArtworkRef('a'));
    await tester.pump();

    expect(find.byType(NoCoverTile), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a failing repository falls back to the no-cover tile', (
    tester,
  ) async {
    final repository = FakeArtworkRepository()..error = Exception('boom');

    await _pump(tester, repository, const ArtworkRef('a'));
    await tester.runAsync(pumpEventQueue);
    await tester.pump();

    expect(find.byType(NoCoverTile), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  FakeArtworkRepository repository,
  ArtworkRef? reference, {
  double size = 56,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [artworkRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: ArtworkImage(artworkRef: reference, size: size),
        ),
      ),
    ),
  );
}

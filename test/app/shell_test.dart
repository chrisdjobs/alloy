import 'package:bars/app/router.dart';
import 'package:bars/app/theme.dart';
import 'package:bars/features/player/presentation/mini_player.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes/fake_playback_engine.dart';

void main() {
  late FakePlaybackEngine engine;

  setUp(() => engine = FakePlaybackEngine());
  tearDown(() => engine.dispose());

  testWidgets('uses bottom navigation when compact', (tester) async {
    await _pumpApp(tester, const Size(400, 800), engine);

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('LIBRARY'), findsOneWidget);
    expect(find.byIcon(AppIcons.home), findsOneWidget);
    expect(find.byIcon(AppIcons.discover), findsOneWidget);
    expect(find.byIcon(AppIcons.library), findsOneWidget);
    expect(find.byIcon(AppIcons.me), findsOneWidget);
    expect(find.byType(MiniPlayer), findsOneWidget);
  });

  testWidgets('uses a sidebar when wide', (tester) async {
    await _pumpApp(tester, const Size(1200, 800), engine);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('LIBRARY'), findsWidgets);
    expect(find.text('ME'), findsWidgets);
    expect(find.byType(MiniPlayer), findsOneWidget);
  });

  testWidgets('switches to the settings branch', (tester) async {
    await _pumpApp(tester, const Size(400, 800), engine);

    await tester.tap(find.byIcon(AppIcons.me));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Library'), findsNothing);
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  Size size,
  FakePlaybackEngine engine,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [playbackEngineProvider.overrideWithValue(engine)],
      child: MaterialApp.router(
        locale: const Locale('en'),
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: createAppRouter(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

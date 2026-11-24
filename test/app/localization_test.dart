import 'package:bars/app/router.dart';
import 'package:bars/app/theme.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes/fake_playback_engine.dart';

void main() {
  testWidgets('renders the Spanish strings', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final engine = FakePlaybackEngine();
    addTearDown(engine.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [playbackEngineProvider.overrideWithValue(engine)],
        child: MaterialApp.router(
          locale: const Locale('es'),
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

    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('BIBLIOTECA'), findsOneWidget);
    expect(find.text('YO'), findsOneWidget);
  });
}

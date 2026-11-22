import 'package:bars/app/router.dart';
import 'package:bars/app/theme.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders the Spanish strings', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(
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
    );
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('BIBLIOTECA'), findsOneWidget);
    expect(find.text('AJUSTES'), findsOneWidget);
  });
}

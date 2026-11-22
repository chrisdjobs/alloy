import 'package:bars/app/router.dart';
import 'package:bars/app/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('uses bottom navigation when compact', (tester) async {
    await _pumpApp(tester, const Size(400, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('LIBRARY'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.byKey(const Key('mini-player-slot')), findsOneWidget);
  });

  testWidgets('uses a sidebar when wide', (tester) async {
    await _pumpApp(tester, const Size(1200, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('LIBRARY'), findsWidgets);
    expect(find.text('SETTINGS'), findsWidgets);
    expect(find.byKey(const Key('mini-player-slot')), findsOneWidget);
  });

  testWidgets('switches to the settings branch', (tester) async {
    await _pumpApp(tester, const Size(400, 800));

    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Library'), findsNothing);
  });
}

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: createAppRouter(),
    ),
  );
  await tester.pumpAndSettle();
}

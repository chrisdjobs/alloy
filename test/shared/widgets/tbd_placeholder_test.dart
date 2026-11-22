import 'package:bars/app/theme.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/tbd_placeholder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders TBD in a rounded container', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Center(child: TbdPlaceholder(width: 120, height: 80)),
      ),
    );

    expect(find.text('TBD'), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(TbdPlaceholder),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.borderRadius, AppRadii.card);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a custom label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Center(child: TbdPlaceholder(label: 'LOGO')),
      ),
    );

    expect(find.text('LOGO'), findsOneWidget);
    expect(find.text('TBD'), findsNothing);
  });
}

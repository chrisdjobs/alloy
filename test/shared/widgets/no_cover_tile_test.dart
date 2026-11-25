import 'package:alloy/shared/design/app_icons.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/widgets/no_cover_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders a muted music-note tile at the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: NoCoverTile(size: 64))),
    );

    final tile = tester.widget<Container>(find.byType(Container));
    expect(tile.constraints, isNotNull);
    expect(find.byType(Icon), findsOneWidget);
    expect(tester.widget<Icon>(find.byType(Icon)).icon, AppIcons.track);

    final sized = tester.getSize(find.byType(Container));
    expect(sized, const Size(64, 64));
  });

  testWidgets('defaults to the library row size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: NoCoverTile())),
    );

    expect(
      tester.getSize(find.byType(Container)),
      const Size(AppSizing.coverRow, AppSizing.coverRow),
    );
  });
}

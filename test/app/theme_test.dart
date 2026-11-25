import 'package:alloy/app/theme.dart';
import 'package:alloy/shared/design/gradient_presets.dart';
import 'package:alloy/shared/design/gradients.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('dark theme exposes the Alloy palette and type scale', () {
    final theme = AppTheme.dark();

    expect(theme.brightness, Brightness.dark);
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.accent);
    expect(theme.scaffoldBackgroundColor, AppGradientPresets.active.base);
    expect(theme.colorScheme.surfaceContainer, AppColors.surface);
    expect(theme.cardTheme.color, AppColors.surface);
    expect(
      theme.textTheme.displayLarge?.fontSize,
      AppTextStyles.display.fontSize,
    );
  });

  test('accent gradient derives stops from the accent', () {
    final gradient = AppGradients.accent(AppColors.accent);

    expect(gradient.colors, hasLength(3));
    expect(gradient.colors[1], AppColors.accent);
    expect(gradient.colors.first, isNot(AppColors.accent));
    expect(gradient.colors.last, isNot(AppColors.accent));
  });

  testWidgets('a screen renders with the theme tokens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Scaffold(
              body: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.card,
                    gradient: AppGradients.accent(theme.colorScheme.primary),
                  ),
                  child: const Text('Alloy', style: AppTextStyles.display),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Alloy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

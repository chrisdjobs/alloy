import 'package:alloy/shared/design/gradient_presets.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the single Material 3 dark theme used on every platform.
abstract final class AppTheme {
  /// Dark theme with [accent] as the primary color and [icons] in the theme.
  ///
  /// [base] defaults to the active gradient preset's base so the Home gradient
  /// fades into the page background instead of showing an edge where it ends.
  static ThemeData dark({
    Color accent = AppColors.accent,
    AppIconSet icons = AppIcons.lucide,
    Color? base,
  }) {
    final background = base ?? AppGradientPresets.active.base;
    // Icon-derived accents can be dark, so the text over them follows the
    // accent's own brightness instead of the fixed design default.
    final onAccent =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? AppColors.textPrimary
        : AppColors.onAccent;
    final colorScheme =
        ColorScheme.dark(
          primary: accent,
          onPrimary: onAccent,
          secondary: accent,
          onSecondary: onAccent,
          surface: AppColors.background,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.onAccent,
        ).copyWith(
          surfaceContainerLowest: AppColors.background,
          surfaceContainerLow: AppColors.background,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surfaceHigh,
          surfaceContainerHighest: AppColors.surfaceHigh,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.outline,
          outlineVariant: AppColors.outline,
          surfaceTint: Colors.transparent,
        );

    final textTheme =
        const TextTheme(
          displayLarge: AppTextStyles.display,
          headlineMedium: AppTextStyles.headline,
          titleLarge: AppTextStyles.title,
          bodyMedium: AppTextStyles.body,
          labelSmall: AppTextStyles.label,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        space: 1,
        thickness: 1,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        elevation: 0,
        height: 72,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: background,
        useIndicator: false,
        labelType: NavigationRailLabelType.none,
        minWidth: 220,
      ),
      extensions: [AlloyVisualTheme(icons: icons)],
    );
  }
}

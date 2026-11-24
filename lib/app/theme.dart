import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the single Material 3 dark theme used on every platform.
abstract final class AppTheme {
  /// Dark theme with [accent] as the primary color and [icons] in the theme.
  static ThemeData dark({
    Color accent = AppColors.accent,
    AppIconSet icons = AppIcons.lucide,
  }) {
    final colorScheme =
        ColorScheme.dark(
          primary: accent,
          onPrimary: AppColors.onAccent,
          secondary: accent,
          onSecondary: AppColors.onAccent,
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
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
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
      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
        height: 72,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.background,
        useIndicator: false,
        labelType: NavigationRailLabelType.none,
        minWidth: 220,
      ),
      extensions: [BarsVisualTheme(icons: icons)],
    );
  }
}

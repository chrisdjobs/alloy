import 'package:alloy/shared/design/app_icons.dart';
import 'package:material_ui/material_ui.dart';

export 'package:alloy/shared/design/app_icons.dart';

/// Visual tokens that follow the user's settings instead of the palette.
///
/// A [ThemeExtension] lets shared widgets read them without importing the
/// settings feature.
@immutable
final class AlloyVisualTheme extends ThemeExtension<AlloyVisualTheme> {
  /// Creates the visual theme.
  const new({required this.icons});

  /// Fallback used when a widget renders outside the app theme.
  static const fallback = AlloyVisualTheme(icons: AppIcons.lucide);

  /// Icon set selected by the user.
  final AppIconSet icons;

  /// Theme extension of [context], or [fallback] without it.
  static AlloyVisualTheme of(BuildContext context) {
    return Theme.of(context).extension<AlloyVisualTheme>() ?? fallback;
  }

  /// Icon set selected in the theme of [context].
  static AppIconSet iconsOf(BuildContext context) => of(context).icons;

  @override
  AlloyVisualTheme copyWith({AppIconSet? icons}) {
    return AlloyVisualTheme(icons: icons ?? this.icons);
  }

  @override
  AlloyVisualTheme lerp(AlloyVisualTheme? other, double t) {
    if (other == null) return this;
    // Glyphs swap instantly; there is nothing to interpolate.
    return t < 0.5 ? this : other;
  }
}

/// Terse access to the visual theme tokens.
extension AlloyVisualThemeContext on BuildContext {
  /// Icon set of the active pack.
  AppIconSet get icons => AlloyVisualTheme.iconsOf(this);
}

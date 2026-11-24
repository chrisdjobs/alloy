import 'package:bars/shared/design/app_icons.dart';
import 'package:material_ui/material_ui.dart';

export 'package:bars/shared/design/app_icons.dart';

/// Visual tokens that follow the user's settings instead of the palette.
///
/// A [ThemeExtension] lets shared widgets read them without importing the
/// settings feature.
@immutable
final class BarsVisualTheme extends ThemeExtension<BarsVisualTheme> {
  /// Creates the visual theme.
  const new({required this.icons});

  /// Fallback used when a widget renders outside the app theme.
  static const fallback = BarsVisualTheme(icons: AppIcons.lucide);

  /// Icon set selected by the user.
  final AppIconSet icons;

  /// Theme extension of [context], or [fallback] without it.
  static BarsVisualTheme of(BuildContext context) {
    return Theme.of(context).extension<BarsVisualTheme>() ?? fallback;
  }

  /// Icon set selected in the theme of [context].
  static AppIconSet iconsOf(BuildContext context) => of(context).icons;

  @override
  BarsVisualTheme copyWith({AppIconSet? icons}) {
    return BarsVisualTheme(icons: icons ?? this.icons);
  }

  @override
  BarsVisualTheme lerp(BarsVisualTheme? other, double t) {
    if (other == null) return this;
    // Glyphs swap instantly; there is nothing to interpolate.
    return t < 0.5 ? this : other;
  }
}

/// Terse access to the visual theme tokens.
extension BarsVisualThemeContext on BuildContext {
  /// Icon set of the active pack.
  AppIconSet get icons => BarsVisualTheme.iconsOf(this);
}

import 'package:material_ui/material_ui.dart';

/// Core palette for the single Bars visual identity.
abstract final class AppColors {
  /// Near-black page background.
  static const Color background = Color(0xFF0D0D0D);

  /// Raised card and panel surface.
  static const Color surface = Color(0xFF1A1A1A);

  /// Higher surface for overlays and menus.
  static const Color surfaceHigh = Color(0xFF242424);

  /// Default accent; user-changeable later.
  static const Color accent = Color(0xFFFFB300);

  /// Text and icons drawn on top of the accent.
  static const Color onAccent = Color(0xFF0D0D0D);

  /// Primary text.
  static const Color textPrimary = Color(0xFFF4F1EA);

  /// Secondary text.
  static const Color textSecondary = Color(0xFFA8A29A);

  /// Placeholder and disabled text.
  static const Color textMuted = Color(0xFF6E6A63);

  /// Borders and dividers.
  static const Color outline = Color(0xFF2E2E2E);

  /// Errors and destructive actions.
  static const Color error = Color(0xFFFF6B6B);
}

/// Spacing scale in logical pixels.
abstract final class AppSpacing {
  /// 4 px.
  static const double xs = 4;

  /// 8 px.
  static const double sm = 8;

  /// 12 px.
  static const double md = 12;

  /// 16 px.
  static const double lg = 16;

  /// 24 px.
  static const double xl = 24;

  /// 32 px.
  static const double xxl = 32;
}

/// Corner radii in logical pixels.
abstract final class AppRadii {
  /// Small radius, 12 px.
  static const double sm = 12;

  /// Medium radius, 16 px.
  static const double md = 16;

  /// Large radius, 24 px.
  static const double lg = 24;

  /// Rounded rectangle used by cards.
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));

  /// Fully rounded pill.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

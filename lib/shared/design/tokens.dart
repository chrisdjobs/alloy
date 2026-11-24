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

  /// Black scrim over a blurred cover.
  ///
  /// Darkening the backdrop only improves text contrast, so secondary text
  /// stays readable on bright covers.
  static const Color backdropScrim = Color(0x73000000);

  /// Minimum contrast ratio for text drawn over a cover-derived background.
  ///
  /// Not a color, but it belongs with the palette: Phase 6 derives gradients
  /// from artwork and must keep text readable (WCAG AA for normal text).
  static const double minCoverTextContrast = 4.5;
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

  /// Horizontal gutter of a page's content.
  static const double page = 20;
}

/// Corner radii in logical pixels.
abstract final class AppRadii {
  /// Small radius, 12 px.
  static const double sm = 12;

  /// Medium radius, 16 px.
  static const double md = 16;

  /// Large radius, 24 px.
  static const double lg = 24;

  /// Rounded-square artwork tiles (library rows, mini-player, now-playing).
  static const double artworkTile = 12;

  /// Rounded rectangle used by cards.
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));

  /// Larger corner radius for floating cards, such as the mini-player.
  static const BorderRadius cardLarge = BorderRadius.all(Radius.circular(lg));

  /// Rounded rectangle used by artwork tiles.
  static const BorderRadius artwork = BorderRadius.all(
    Radius.circular(artworkTile),
  );

  /// Large artwork used by the now-playing screen.
  static const BorderRadius artworkLarge = BorderRadius.all(
    Radius.circular(md),
  );

  /// Fully rounded pill.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// Fixed sizes shared by the player and library surfaces.
abstract final class AppSizing {
  /// Cover thumbnail in a library row.
  static const double coverRow = 48;

  /// Height of a library row, cover included.
  static const double trackRow = 58;

  /// Cover thumbnail in the mini-player.
  static const double coverMiniPlayer = 44;

  /// Maximum width of the now-playing content on wide layouts.
  static const double nowPlayingMaxWidth = 520;

  /// Diameter of the round play/pause button.
  static const double nowPlayingPlayButton = 64;

  /// Width of a square icon button in a header row.
  static const double iconButton = 48;

  /// Vertical distance a downward swipe needs to close the player.
  static const double nowPlayingDismissDistance = 96;

  /// Thickness of the accent seek bar.
  static const double seekBarHeight = 3;

  /// Touch target around the seek bar.
  static const double seekBarTouchHeight = 24;
}

/// Motion durations shared by the app.
abstract final class AppDurations {
  /// Cross-fade of the cover-derived gradient when the track changes.
  static const Duration gradientFade = Duration(milliseconds: 350);
}

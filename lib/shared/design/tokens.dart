import 'package:material_ui/material_ui.dart';

/// Core palette for the single Alloy visual identity.
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

  /// Active pill of the bottom bar: a rounded square, not a capsule.
  static const BorderRadius navPill = BorderRadius.all(Radius.circular(sm));

  /// Fully rounded pill.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  /// Caps of the bars of the playing indicator.
  static const BorderRadius playingBar = BorderRadius.all(Radius.circular(2));

  /// Caps of the bars of the Home activity chart.
  static const BorderRadius activityBar = BorderRadius.all(Radius.circular(2));

  /// Tiles inside a cover collage.
  static const BorderRadius collageTile = BorderRadius.all(Radius.circular(2));
}

/// Fixed sizes shared by the player and library surfaces.
abstract final class AppSizing {
  /// Cover thumbnail in a library row.
  static const double coverRow = 48;

  /// Height of a library row, cover included.
  static const double trackRow = 60;

  /// Width of the underline under the active library tab.
  static const double tabUnderlineWidth = 38;

  /// Thickness of the underline under the active library tab.
  static const double tabUnderlineHeight = 2;

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
  static const double waveformHeight = 40;

  /// Width of one bar of the waveform seek bar.
  static const double waveformBarWidth = 2;

  /// Gap between two bars of the waveform seek bar.
  static const double waveformBarGap = 2;

  /// Height of the compact bottom bar.
  static const double navBarHeight = 68;

  /// Width of the active pill in the compact bottom bar.
  static const double navPillWidth = 56;

  /// Height of the active pill in the compact bottom bar.
  static const double navPillHeight = 32;

  /// Icon size inside the bottom bar.
  static const double navIcon = 20;

  /// Height of a quick-access card on the Home screen.
  static const double quickAccessHeight = 100;

  /// Height of the Home activity chart's plot area.
  static const double activityChartHeight = 96;

  /// Gap between two bars of the Home activity chart.
  static const double activityBarGap = 2;

  /// Height of the segmented lyrics bar of the statistics card.
  static const double lyricsBarHeight = 8;

  /// Diameter of a legend dot of the lyrics breakdown.
  static const double lyricsDot = 10;

  /// Shortest bar of the Home activity chart, used for days without plays.
  static const double activityBarMinHeight = 2;

  /// Cover size of the Home carousels.
  static const double homeCarouselCover = 120;

  /// Height of a Home carousel, cover plus its two text lines.
  static const double homeCarouselHeight = 176;

  /// Height of the Home mix carousel, cover plus a two-line description.
  static const double homeMixCarouselHeight = 192;

  /// Gap between the tiles of a cover collage.
  static const double collageGap = 2;

  /// Maximum size of the discovery card.
  static const double discoverCardMax = 420;

  /// Diameter of the round play button of the discovery deck.
  static const double discoverPlayButton = 64;

  /// Diameter of the secondary discovery actions.
  static const double discoverActionButton = 52;

  /// Width of the grab handle at the top of a bottom sheet.
  static const double sheetHandleWidth = 40;

  /// Height of the grab handle at the top of a bottom sheet.
  static const double sheetHandleHeight = 4;

  /// Icon size inside a filter chip.
  static const double chipIcon = 16;

  /// Shortest bar of the playing indicator drawn over a library cover.
  static const double playingBarMinHeight = 6;

  /// Tallest bar of the playing indicator drawn over a library cover.
  static const double playingBarMaxHeight = 18;

  /// Width of one bar of the playing indicator.
  static const double playingBarWidth = 3;

  /// Space on each side of a playing-indicator bar.
  static const double playingBarGap = 2;

  /// Diameter of an accent swatch in the appearance settings.
  static const double accentSwatch = 36;

  /// Box of an accent swatch, selected ring included.
  static const double accentSwatchBox = 44;

  /// Thickness of the ring around the selected accent swatch.
  static const double accentSwatchRing = 2;

  /// Diameter of the identity avatar on the Me screen.
  static const double profileAvatar = 68;

  /// Height of the Home glow box. It is taller than the header content so the
  /// vertical fade of `PresetGlow` has room to reach zero.
  static const double homeGlowHeight = 320;

  /// Icon size of a row in the settings screens.
  static const double settingsRowIcon = 24;
}

/// Motion durations shared by the app.
abstract final class AppDurations {
  /// Cross-fade of the cover-derived gradient when the track changes.
  static const Duration gradientFade = Duration(milliseconds: 350);

  /// Highlight change of the bottom bar.
  static const Duration navPill = Duration(milliseconds: 180);

  /// Travel of the bottom-bar highlight between two tabs.
  static const Duration navSlide = Duration(milliseconds: 260);

  /// Shrink of a bottom-bar icon while it is pressed.
  static const Duration navPress = Duration(milliseconds: 90);

  /// Cross-fade between the top-level branches of the shell.
  static const Duration branchFade = Duration(milliseconds: 220);

  /// Slide of the now-playing screen in from the mini-player.
  static const Duration playerOpen = Duration(milliseconds: 320);

  /// Slide of the now-playing screen back down to the mini-player.
  static const Duration playerClose = Duration(milliseconds: 260);
}

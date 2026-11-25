import 'package:material_ui/material_ui.dart';

/// Type scale for the Alloy visual identity.
abstract final class AppTextStyles {
  /// Large display text.
  static const TextStyle display = TextStyle(
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );

  /// Screen headline.
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  /// Section title.
  static const TextStyle title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Body copy.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// Title of a track in a list row.
  static const TextStyle trackTitle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Track title on the now-playing screen.
  static const TextStyle playerTitle = TextStyle(
    fontSize: 24,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  /// Album name in the now-playing header.
  static const TextStyle playerHeader = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Times and technical line under the now-playing seek bar.
  static const TextStyle playerMeta = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Artist line under a track title.
  static const TextStyle trackArtist = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  /// Uppercase labels and captions.
  static const TextStyle label = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );

  /// Uppercase section header, such as "Recently added".
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  /// Prominent uppercase action label, such as the shuffle row.
  static const TextStyle action = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}

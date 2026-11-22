import 'package:material_ui/material_ui.dart';

/// Type scale for the Bars visual identity.
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

  /// Uppercase labels and captions.
  static const TextStyle label = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );
}

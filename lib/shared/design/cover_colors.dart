import 'dart:math' as math;

/// Derives readable colors from cover art.
///
/// Pure Dart on purpose: the artwork pipeline runs it inside an isolate,
/// where Flutter's `Color` type is not available.
abstract final class CoverColors {
  /// WCAG AA contrast ratio for normal text.
  static const double minContrast = 4.5;

  /// ARGB of `AppColors.textPrimary`; darkening targets this text.
  static const int defaultTextArgb = 0xFFF4F1EA;

  /// ARGB of `AppColors.surface`, used when a cover is pure black.
  static const int fallbackArgb = 0xFF1A1A1A;

  /// Lowest backdrop luminance, so the gradient stays visible.
  static const double _minLuminance = 0.02;

  /// Darkens [dominantArgb] until text of [textArgb] reaches [minContrast]
  /// against it, keeping the hue of the cover.
  ///
  /// The returned color is always opaque; its raw cover value is never returned
  /// unchanged because covers can be as bright as white.
  static int backdropFor(
    int dominantArgb, {
    int textArgb = defaultTextArgb,
    double minContrast = minContrast,
  }) {
    final red = (dominantArgb >> 16) & 0xFF;
    final green = (dominantArgb >> 8) & 0xFF;
    final blue = dominantArgb & 0xFF;
    final luminance = _luminance(red, green, blue);

    if (luminance <= 0) return fallbackArgb;

    final maxLuminance = _readableLuminance(textArgb, minContrast);
    final target = luminance.clamp(_minLuminance, maxLuminance);
    var scale = target / luminance;
    var backdrop = _scale(red, green, blue, scale);

    // Rounding to 8 bits can land a hair above the cap; step down until the
    // guarantee holds.
    for (var attempt = 0; attempt < 8; attempt++) {
      if (contrastRatio(backdrop, textArgb) >= minContrast) break;
      scale *= 0.98;
      backdrop = _scale(red, green, blue, scale);
    }
    return backdrop;
  }

  /// WCAG contrast ratio between two opaque ARGB colors.
  static double contrastRatio(int argb1, int argb2) {
    final first = relativeLuminance(argb1);
    final second = relativeLuminance(argb2);
    final lighter = math.max(first, second);
    final darker = math.min(first, second);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// WCAG relative luminance of an opaque ARGB color.
  static double relativeLuminance(int argb) {
    return _luminance((argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF);
  }

  static double _readableLuminance(int textArgb, double minContrast) {
    return (relativeLuminance(textArgb) + 0.05) / minContrast - 0.05;
  }

  static int _scale(int red, int green, int blue, double scale) {
    int channel(int value) {
      final linear = _toLinear(value / 255) * scale;
      return (_toSrgb(linear.clamp(0.0, 1.0)) * 255).round().clamp(0, 255);
    }

    return 0xFF000000 |
        (channel(red) << 16) |
        (channel(green) << 8) |
        channel(blue);
  }

  static double _luminance(int red, int green, int blue) {
    return 0.2126 * _toLinear(red / 255) +
        0.7152 * _toLinear(green / 255) +
        0.0722 * _toLinear(blue / 255);
  }

  static double _toLinear(double channel) {
    return channel <= 0.04045
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _toSrgb(double linear) {
    return linear <= 0.0031308
        ? linear * 12.92
        : 1.055 * math.pow(linear, 1 / 2.4) - 0.055;
  }
}

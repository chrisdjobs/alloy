import 'package:bars/shared/design/cover_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const text = CoverColors.defaultTextArgb;

  /// A deterministic grid of hues and luminances, including pure grays.
  Iterable<int> coverColors() sync* {
    for (var r = 0; r <= 255; r += 51) {
      for (var g = 0; g <= 255; g += 51) {
        for (var b = 0; b <= 255; b += 51) {
          yield 0xFF000000 | (r << 16) | (g << 8) | b;
        }
      }
    }
  }

  test('every cover color gets a backdrop readable in white', () {
    for (final cover in coverColors()) {
      final backdrop = CoverColors.backdropFor(cover);
      expect(
        CoverColors.contrastRatio(backdrop, text),
        greaterThanOrEqualTo(CoverColors.minContrast),
        reason: 'cover ${cover.toRadixString(16)}',
      );
      expect(backdrop >> 24, 0xFF, reason: 'backdrop must stay opaque');
    }
  });

  test('the raw cover color is never used behind text', () {
    for (final cover in [0xFFFFFFFF, 0xFFFFEB3B, 0xFF90CAF9]) {
      final backdrop = CoverColors.backdropFor(cover);
      expect(
        CoverColors.contrastRatio(cover, text),
        lessThan(CoverColors.minContrast),
      );
      expect(backdrop, isNot(cover));
    }
  });

  test('grayscale covers keep their neutral tint', () {
    for (final gray in [0xFF202020, 0xFF808080, 0xFFF0F0F0]) {
      final backdrop = CoverColors.backdropFor(gray);
      final red = (backdrop >> 16) & 0xFF;
      final green = (backdrop >> 8) & 0xFF;
      final blue = backdrop & 0xFF;
      expect(red, green);
      expect(green, blue);
    }
  });

  test('pure black falls back to the surface color', () {
    expect(CoverColors.backdropFor(0xFF000000), CoverColors.fallbackArgb);
  });

  test('relative luminance matches the WCAG anchors', () {
    expect(CoverColors.relativeLuminance(0xFFFFFFFF), closeTo(1, 0.001));
    expect(CoverColors.relativeLuminance(0xFF000000), 0);
    expect(
      CoverColors.contrastRatio(0xFFFFFFFF, 0xFF000000),
      closeTo(21, 0.01),
    );
  });
}

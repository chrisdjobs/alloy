import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/shared/design/cover_colors.dart';
import 'package:image/image.dart' as img;
import 'package:material_color_utilities/quantize/quantizer_celebi.dart';
import 'package:material_color_utilities/score/score.dart';

/// Artwork decoded once into the variants the UI needs.
final class ExtractedArtwork {
  /// Creates the extracted variants.
  const new({
    required this.small,
    required this.large,
    required this.backdrop,
    required this.backdropColorArgb,
  });

  /// Encoded cover at [ArtworkPixels.small].
  final Uint8List small;

  /// Encoded cover at [ArtworkPixels.large].
  final Uint8List large;

  /// Encoded tiny blurred cover for backgrounds.
  final Uint8List backdrop;

  /// Dominant color darkened until text stays readable.
  final int backdropColorArgb;
}

/// Decodes, resizes, blurs and color-extracts a cover away from the UI thread.
final class CoverExtractor {
  /// Creates the extractor.
  const new();

  /// Returns the display variants of [bytes], or null when it is not an image.
  Future<ExtractedArtwork?> extract(Uint8List bytes) {
    return Isolate.run(() => _extract(bytes));
  }
}

Future<ExtractedArtwork?> _extract(Uint8List bytes) async {
  final decoded = img.decodeImage(bytes);
  if (decoded == null || decoded.width <= 0 || decoded.height <= 0) return null;

  final side = math.min(decoded.width, decoded.height);
  final squareSize = math.min(side, ArtworkPixels.large);
  final square = img.copyResizeCropSquare(
    decoded,
    size: squareSize,
    interpolation: img.Interpolation.average,
  );

  final small = img.copyResize(
    square,
    width: ArtworkPixels.small,
    height: ArtworkPixels.small,
    interpolation: img.Interpolation.average,
  );
  final backdrop = img.gaussianBlur(
    img.copyResize(
      square,
      width: ArtworkPixels.backdrop,
      height: ArtworkPixels.backdrop,
      interpolation: img.Interpolation.average,
    ),
    radius: ArtworkPixels.backdropBlur,
  );

  return ExtractedArtwork(
    small: img.encodeJpg(small, quality: 85),
    large: img.encodeJpg(square, quality: 85),
    backdrop: img.encodeJpg(backdrop, quality: 70),
    backdropColorArgb: await _dominantColor(square),
  );
}

Future<int> _dominantColor(img.Image square) async {
  final sample = img.copyResize(
    square,
    width: 32,
    height: 32,
    interpolation: img.Interpolation.average,
  );
  final pixels = <int>[
    for (final pixel in sample)
      (0xFF << 24) |
          (pixel.r.toInt() << 16) |
          (pixel.g.toInt() << 8) |
          pixel.b.toInt(),
  ];
  final quantized = await QuantizerCelebi().quantize(pixels, 32);
  final ranked = Score.score(quantized.colorToCount, filter: false, desired: 1);
  final dominant = ranked.isEmpty ? _average(pixels) : ranked.first;
  return CoverColors.backdropFor(dominant);
}

int _average(List<int> pixels) {
  var red = 0;
  var green = 0;
  var blue = 0;
  for (final pixel in pixels) {
    red += (pixel >> 16) & 0xFF;
    green += (pixel >> 8) & 0xFF;
    blue += pixel & 0xFF;
  }
  final count = math.max(pixels.length, 1);
  return 0xFF000000 |
      ((red ~/ count) << 16) |
      ((green ~/ count) << 8) |
      (blue ~/ count);
}

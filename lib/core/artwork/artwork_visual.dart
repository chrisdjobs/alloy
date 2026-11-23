import 'dart:typed_data';

import 'package:bars/core/artwork/artwork_ref.dart';

/// Resolution a cover image is cached and displayed at.
enum ArtworkSize {
  /// Library rows and the mini-player.
  small,

  /// Now-playing screen.
  large,
}

/// Pixel dimensions of the cached artwork variants.
///
/// They are cache constants, not design tokens: the UI scales the images down
/// to its logical size.
abstract final class ArtworkPixels {
  /// Long edge of the small variant, enough for a 56 dp tile at 3x.
  static const int small = 192;

  /// Long edge of the large variant used by the now-playing screen.
  static const int large = 640;

  /// Size of the tiny image that is blurred once for backgrounds.
  static const int backdrop = 24;

  /// Gaussian blur radius applied to [backdrop] before scaling it up.
  static const int backdropBlur = 6;
}

/// Everything the UI needs to show one cover.
final class ArtworkVisual {
  /// Creates a visual from encoded image [cover] bytes.
  const new({
    required this.cover,
    required this.backdrop,
    required this.backdropColorArgb,
  });

  /// Encoded (JPEG) cover at the requested [ArtworkSize].
  final Uint8List cover;

  /// Tiny pre-blurred cover for backgrounds; never a live filter.
  final Uint8List backdrop;

  /// Dominant color of the cover, darkened until text stays readable.
  final int backdropColorArgb;
}

/// Resolves opaque [ArtworkRef]s to displayable images.
///
/// Implementations extract, resize and cache off the UI thread, so a source
/// that does not map to local files can supply covers through the same
/// contract later.
abstract interface class ArtworkRepository {
  /// Returns the cover behind [ref] at [size], or null when there is none.
  Future<ArtworkVisual?> visualFor(ArtworkRef ref, ArtworkSize size);
}

/// Loads the raw, unprocessed cover bytes a source has for [ref].
typedef ArtworkBytesLoader = Future<Uint8List?> Function(ArtworkRef ref);

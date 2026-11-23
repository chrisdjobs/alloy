import 'dart:typed_data';

/// Reads the cover bytes a local audio file can offer.
///
/// Implementations run off the UI thread: a cache miss re-reads the tags or
/// the folder image, which must never happen inside a frame.
abstract interface class LocalCoverReader {
  /// Returns the embedded cover of [audioFilePath], or an image named
  /// `cover`, `folder` or `front` next to it.
  Future<Uint8List?> coverFor(String audioFilePath);
}

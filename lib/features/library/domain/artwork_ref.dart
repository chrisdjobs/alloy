import 'package:freezed_annotation/freezed_annotation.dart';

part 'artwork_ref.freezed.dart';

/// Opaque reference to a cover image.
///
/// It is a content hash, never a file path: the artwork repository resolves it
/// to actual bytes, so sources that do not map to local files (Jellyfin later)
/// can supply covers through the same pipeline.
@freezed
abstract class ArtworkRef with _$ArtworkRef {
  /// Wraps the content [hash] of a cover image.
  // Freezed only recognizes the class name in redirecting factories.
  // ignore: unnecessary_type_name_in_constructor
  const factory ArtworkRef(String hash) = _ArtworkRef;
}

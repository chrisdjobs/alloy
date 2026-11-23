import 'package:bars/features/library/domain/artwork_ref.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';

/// A playable track, independent of the source it comes from.
///
/// Local files and remote sources share this model; [sourceItemId] is whatever
/// the owning `MusicSource` uses to address the item.
@freezed
abstract class Track with _$Track {
  /// Creates a track.
  // Freezed only recognizes the class name in redirecting factories.
  // ignore: unnecessary_type_name_in_constructor
  const factory Track({
    required String id,
    required String sourceId,
    required String sourceItemId,
    required String title,
    String? artist,
    String? album,
    int? trackNumber,
    int? durationMs,
    ArtworkRef? artworkRef,
    int? sampleRateHz,
    int? bitrateKbps,
    String? format,
  }) = _Track;
}

/// Convenience values derived from [Track] metadata.
extension TrackMetadata on Track {
  /// Track length, when the source reported one.
  Duration? get duration =>
      durationMs == null ? null : Duration(milliseconds: durationMs!);
}

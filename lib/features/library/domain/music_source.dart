import 'package:bars/features/library/domain/track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_source.freezed.dart';

/// A place tracks come from: local files now, Jellyfin later.
///
/// The library layer never assumes a track is a file; it asks the owning
/// source for a playable URI instead.
abstract interface class MusicSource {
  /// Stable identifier stored on every track of this source.
  String get id;

  /// Scans [folderPath] and reports progress until the source is exhausted.
  ///
  /// Scanned tracks are stored by the implementation so [listTracks] reflects
  /// them. The stream closes after the last event.
  Stream<ScanProgress> scan(String folderPath);

  /// Emits the stored tracks on subscribe and after every change.
  Stream<List<Track>> listTracks();

  /// Turns [track] into the URI the playback engine opens.
  Uri resolveUri(Track track);
}

/// Progress of a [MusicSource.scan].
@freezed
abstract class ScanProgress with _$ScanProgress {
  /// Creates a progress snapshot.
  // Freezed only recognizes the class name in redirecting factories.
  // ignore: unnecessary_type_name_in_constructor
  const factory ScanProgress({
    required int filesFound,
    required int filesRead,
    @Default(false) bool isComplete,
  }) = _ScanProgress;
}

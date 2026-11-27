import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/domain/track.dart';

/// Supplies the lyrics of a track.
///
/// The first implementation reads the lyrics embedded in the file tags; online
/// providers (LRCLIB or similar) can implement the same contract later without
/// touching the player.
abstract interface class LyricsProvider {
  /// Lyrics of [track], or `null` when the track has none.
  Future<Result<String?>> lyricsFor(Track track);
}

import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/player/domain/playback_state.dart';

/// Resolves the URI the engine opens for [track].
typedef TrackUriResolver = Uri Function(Track track);

/// Plays a queue of tracks, hiding the platform backend.
///
/// Implementations live in `data/`; bootstrap picks one per platform.
abstract interface class PlaybackEngine {
  /// Snapshot of the player at the moment of reading.
  PlaybackState get currentState;

  /// Emits the current snapshot on subscribe, then every state change.
  Stream<PlaybackState> get stateStream;

  /// Emits the position about every 200 ms while playing.
  Stream<Duration> get positionStream;

  /// Emits the loaded track on subscribe and whenever it changes.
  Stream<Track?> get currentTrackStream;

  /// Loads [tracks] and positions the queue at [initialIndex].
  Future<Result<void>> loadQueue(List<Track> tracks, {int initialIndex = 0});

  /// Starts or resumes playback.
  Future<Result<void>> play();

  /// Pauses playback.
  Future<Result<void>> pause();

  /// Seeks to [position] inside the current track.
  Future<Result<void>> seek(Duration position);

  /// Stops playback and releases the current source.
  Future<Result<void>> stop();

  /// Skips to the next track in the queue.
  Future<Result<void>> skipNext();

  /// Skips to the previous track in the queue.
  Future<Result<void>> skipPrevious();

  /// Enables or disables shuffle for the current queue.
  Future<Result<void>> setShuffle(bool enabled);

  /// Sets how playback continues after the current track.
  Future<Result<void>> setRepeatMode(RepeatMode mode);

  /// Releases the platform player.
  Future<void> dispose();
}

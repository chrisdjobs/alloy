import 'package:bars/features/library/domain/track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_state.freezed.dart';

/// Stage of the current source in the playback pipeline.
enum PlaybackProcessingState {
  /// Nothing is loaded.
  idle,

  /// A source is being loaded.
  loading,

  /// Playback is waiting for enough data.
  buffering,

  /// Ready to play.
  ready,

  /// The end of the current source was reached.
  completed,
}

/// Immutable snapshot of what the playback engine is doing.
@freezed
abstract class PlaybackState with _$PlaybackState {
  /// Creates a snapshot.
  // Freezed only recognizes the class name in redirecting factories.
  // ignore: unnecessary_type_name_in_constructor
  const factory PlaybackState({
    @Default(false) bool playing,
    @Default(PlaybackProcessingState.idle)
    PlaybackProcessingState processingState,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration buffered,
    @Default(1) double speed,
    @Default(false) bool shuffle,
    @Default(RepeatMode.off) RepeatMode repeatMode,
    int? queueIndex,
    int? queueLength,
    Duration? duration,
    Track? track,
  }) = _PlaybackState;
}

/// How the queue behaves after the current track ends.
enum RepeatMode {
  /// Stop after the last track.
  off,

  /// Loop the whole queue.
  all,

  /// Loop the current track.
  one,
}

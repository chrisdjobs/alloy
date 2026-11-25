import 'package:alloy/core/failure.dart';
import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/player/data/audio_handler.dart';
import 'package:alloy/features/player/domain/playback_engine.dart';
import 'package:alloy/features/player/domain/playback_state.dart';
import 'package:audio_service/audio_service.dart'
    show AudioServiceRepeatMode, AudioServiceShuffleMode;
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

/// [PlaybackEngine] backed by just_audio and a [AlloyAudioHandler].
///
/// Android and Linux only differ in how the handler is started, so both
/// platform engines extend this class.
base class AudioServicePlaybackEngine implements PlaybackEngine {
  /// Creates an engine around [handler].
  new({required this.handler});

  /// Handler that owns the player and the media session.
  final AlloyAudioHandler handler;
  List<Track> _queue = const [];

  AudioPlayer get _player => handler.player;

  @override
  PlaybackState get currentState => _snapshot(_player.playerState);

  @override
  Stream<PlaybackState> get stateStream => Rx.combineLatest2(
    _player.playerStateStream,
    _player.sequenceStateStream,
    (_, _) => currentState,
  ).distinct();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Track?> get currentTrackStream =>
      _player.currentIndexStream.map(_trackAt);

  @override
  Future<Result<void>> loadQueue(List<Track> tracks, {int initialIndex = 0}) {
    if (tracks.isEmpty) {
      return Future.value(
        const Err(Failure.unknown(message: 'Cannot load an empty queue')),
      );
    }
    _queue = List.unmodifiable(tracks);
    return _guard(
      () => handler.setPlaylist(_queue, initialIndex: initialIndex),
    );
  }

  @override
  Future<Result<void>> play() => _guard(handler.play);

  @override
  Future<Result<void>> pause() => _guard(handler.pause);

  @override
  Future<Result<void>> seek(Duration position) =>
      _guard(() => handler.seek(position));

  @override
  Future<Result<void>> stop() => _guard(handler.stop);

  @override
  Future<Result<void>> skipNext() => _guard(handler.skipToNext);

  @override
  Future<Result<void>> skipPrevious() => _guard(handler.skipToPrevious);

  @override
  Future<Result<void>> setShuffle(bool enabled) => _guard(
    () => handler.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    ),
  );

  @override
  Future<Result<void>> setRepeatMode(RepeatMode mode) => _guard(
    () => handler.setRepeatMode(switch (mode) {
      RepeatMode.off => AudioServiceRepeatMode.none,
      RepeatMode.all => AudioServiceRepeatMode.all,
      RepeatMode.one => AudioServiceRepeatMode.one,
    }),
  );

  @override
  Future<void> dispose() => handler.dispose();

  PlaybackState _snapshot(PlayerState state) {
    final index = _player.currentIndex;
    final track = _trackAt(index);
    return PlaybackState(
      playing: state.playing,
      processingState: _processingState(state.processingState),
      position: _player.position,
      buffered: _player.bufferedPosition,
      speed: _player.speed,
      shuffle: _player.shuffleModeEnabled,
      repeatMode: switch (_player.loopMode) {
        LoopMode.off => RepeatMode.off,
        LoopMode.all => RepeatMode.all,
        LoopMode.one => RepeatMode.one,
      },
      queueIndex: index,
      queueLength: _queue.isEmpty ? null : _queue.length,
      duration: _player.duration ?? track?.duration,
      track: track,
    );
  }

  Track? _trackAt(int? index) {
    if (index == null || index < 0 || index >= _queue.length) return null;
    return _queue[index];
  }

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Ok<void>(null);
    } on Exception catch (error, stackTrace) {
      return Err(
        Failure.unknown(
          message: 'Playback command failed',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  PlaybackProcessingState _processingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => PlaybackProcessingState.idle,
      ProcessingState.loading => PlaybackProcessingState.loading,
      ProcessingState.buffering => PlaybackProcessingState.buffering,
      ProcessingState.ready => PlaybackProcessingState.ready,
      ProcessingState.completed => PlaybackProcessingState.completed,
    };
  }
}

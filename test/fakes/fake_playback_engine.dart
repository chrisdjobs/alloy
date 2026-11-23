import 'dart:async';

import 'package:bars/core/failure.dart';
import 'package:bars/core/result.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/domain/playback_engine.dart';
import 'package:bars/features/player/domain/playback_state.dart';

/// In-memory [PlaybackEngine] for notifier and widget tests.
final class FakePlaybackEngine implements PlaybackEngine {
  final _states = StreamController<PlaybackState>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  final _tracks = StreamController<Track?>.broadcast();

  PlaybackState _state = const PlaybackState();

  /// Queue received by the last [loadQueue] call.
  List<Track> queue = const [];

  /// Index received by the last [loadQueue] call.
  int? initialIndex;

  /// Number of [play] calls.
  int playCalls = 0;

  /// Number of [pause] calls.
  int pauseCalls = 0;

  /// Number of [stop] calls.
  int stopCalls = 0;

  /// Number of [skipNext] calls.
  int skipNextCalls = 0;

  /// Number of [skipPrevious] calls.
  int skipPreviousCalls = 0;

  /// Positions received by [seek], in order.
  final List<Duration> seeks = [];

  /// When set, the next command fails with this failure instead of running.
  Failure? nextFailure;

  @override
  PlaybackState get currentState => _state;

  @override
  Stream<PlaybackState> get stateStream => _states.stream;

  @override
  Stream<Duration> get positionStream => _positions.stream;

  @override
  Stream<Track?> get currentTrackStream => _tracks.stream;

  @override
  Future<Result<void>> loadQueue(
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    queue = List.unmodifiable(tracks);
    this.initialIndex = initialIndex;
    final track = tracks[initialIndex];
    _emit(
      _state.copyWith(
        processingState: PlaybackProcessingState.ready,
        queueIndex: initialIndex,
        track: track,
        duration: track.duration,
        position: Duration.zero,
      ),
    );
    _tracks.add(track);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> play() async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    playCalls++;
    _emit(_state.copyWith(playing: true));
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> pause() async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    pauseCalls++;
    _emit(_state.copyWith(playing: false));
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> seek(Duration position) async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    seeks.add(position);
    _emit(_state.copyWith(position: position));
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> stop() async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    stopCalls++;
    _emit(
      _state.copyWith(
        playing: false,
        processingState: PlaybackProcessingState.idle,
      ),
    );
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> skipNext() async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    skipNextCalls++;
    _moveTo((_state.queueIndex ?? 0) + 1);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> skipPrevious() async {
    final failure = _takeFailure();
    if (failure != null) return failure;

    skipPreviousCalls++;
    _moveTo((_state.queueIndex ?? 0) - 1);
    return const Ok<void>(null);
  }

  /// Emits [position] on [positionStream] without going through [seek].
  void emitPosition(Duration position) {
    _emit(_state.copyWith(position: position));
    _positions.add(position);
  }

  /// Emits [track] on [currentTrackStream].
  void emitTrack(Track? track) {
    _emit(_state.copyWith(track: track));
    _tracks.add(track);
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await _positions.close();
    await _tracks.close();
  }

  Result<void>? _takeFailure() {
    final failure = nextFailure;
    if (failure == null) return null;
    nextFailure = null;
    return Err<void>(failure);
  }

  void _emit(PlaybackState next) {
    _state = next;
    _states.add(next);
  }

  void _moveTo(int index) {
    if (index < 0 || index >= queue.length) return;
    final track = queue[index];
    _emit(
      _state.copyWith(
        queueIndex: index,
        track: track,
        duration: track.duration,
        position: Duration.zero,
      ),
    );
    _tracks.add(track);
  }
}

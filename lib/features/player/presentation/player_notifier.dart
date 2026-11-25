import 'dart:async';
import 'dart:math';

import 'package:alloy/core/logger.dart';
import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/player/domain/playback_engine.dart';
import 'package:alloy/features/player/domain/playback_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_notifier.g.dart';

/// Engine behind the player; bootstrap overrides it with the platform engine.
final playbackEngineProvider = Provider<PlaybackEngine>((ref) {
  throw UnimplementedError(
    'playbackEngineProvider must be overridden during bootstrap',
  );
});

/// Exposes playback state and actions to the UI.
@Riverpod(keepAlive: true)
class PlayerNotifier extends _$PlayerNotifier {
  @override
  Future<PlaybackState> build() async {
    final engine = ref.watch(playbackEngineProvider);
    var ready = false;
    var disposed = false;
    var latest = engine.currentState;

    // Events emitted while build is still running are folded into `latest`
    // instead of being written to `state`, which is not initialized yet.
    void publish(PlaybackState next) {
      latest = next;
      if (ready && !disposed) state = AsyncData(next);
    }

    final subscriptions = <StreamSubscription<Object?>>[
      engine.stateStream.listen(publish),
      engine.positionStream.listen(
        (position) => publish(latest.copyWith(position: position)),
      ),
      engine.currentTrackStream.listen(
        (track) => publish(latest.copyWith(track: track)),
      ),
    ];

    ref.onDispose(() {
      disposed = true;
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    });

    ready = true;
    return latest;
  }

  /// Loads [tracks] and starts playing the one at [index].
  Future<void> loadQueueAndPlay(List<Track> tracks, int index) async {
    if (tracks.isEmpty) return;
    final engine = ref.read(playbackEngineProvider);
    final loaded = await engine.loadQueue(tracks, initialIndex: index);
    _report(loaded);
    if (loaded.isErr) return;
    _report(await engine.play());
  }

  /// Loads [tracks] in shuffle mode, starting at a random track.
  Future<void> shuffleAll(List<Track> tracks) async {
    if (tracks.isEmpty) return;
    final engine = ref.read(playbackEngineProvider);
    final loaded = await engine.loadQueue(
      tracks,
      initialIndex: Random().nextInt(tracks.length),
    );
    _report(loaded);
    if (loaded.isErr) return;
    _report(await engine.setShuffle(true));
    _report(await engine.play());
  }

  /// Pauses when playing, resumes otherwise.
  Future<void> togglePlayPause() async {
    final current = state.value;
    if (current == null) return;
    final engine = ref.read(playbackEngineProvider);
    _report(await (current.playing ? engine.pause() : engine.play()));
  }

  /// Skips to the next track.
  Future<void> next() async {
    _report(await ref.read(playbackEngineProvider).skipNext());
  }

  /// Skips to the previous track.
  Future<void> previous() async {
    _report(await ref.read(playbackEngineProvider).skipPrevious());
  }

  /// Seeks inside the current track.
  Future<void> seek(Duration position) async {
    _report(await ref.read(playbackEngineProvider).seek(position));
  }

  /// Enables or disables shuffle for the queue.
  Future<void> setShuffle(bool enabled) async {
    _report(await ref.read(playbackEngineProvider).setShuffle(enabled));
  }

  /// Changes how the queue repeats.
  Future<void> setRepeatMode(RepeatMode mode) async {
    _report(await ref.read(playbackEngineProvider).setRepeatMode(mode));
  }

  /// Stops playback.
  Future<void> stop() async {
    _report(await ref.read(playbackEngineProvider).stop());
  }

  void _report(Result<void> result) {
    final failure = result.failureOrNull;
    if (failure == null) return;
    Logger.error(
      failure.message ?? 'Playback command failed',
      error: failure.cause,
      stackTrace: failure.stackTrace,
    );
    state = AsyncError(failure, failure.stackTrace ?? StackTrace.current);
  }
}

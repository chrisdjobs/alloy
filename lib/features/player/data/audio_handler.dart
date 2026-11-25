import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/player/domain/playback_engine.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Connects just_audio to the system media session.
///
/// Android renders it as the media notification, Linux exposes it over MPRIS.
final class AlloyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  /// Creates a handler whose player opens tracks through [resolveUri].
  new({required this.resolveUri}) {
    player
      ..playerStateStream.listen(_broadcastState)
      ..currentIndexStream.listen(_broadcastCurrentItem);
  }

  /// Turns a track into the URI the player should open.
  final TrackUriResolver resolveUri;

  /// Player that does the actual decoding.
  final AudioPlayer player = AudioPlayer();

  /// Replaces the queue and preloads the track at [initialIndex].
  Future<void> setPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    queue.add([
      for (final track in tracks)
        MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist,
          album: track.album,
          duration: track.duration,
        ),
    ]);
    await player.setAudioSources([
      for (final track in tracks)
        AudioSource.uri(resolveUri(track), tag: track.id),
    ], initialIndex: initialIndex);
    mediaItem.add(queue.value[initialIndex]);
  }

  /// Releases the platform player.
  Future<void> dispose() => player.dispose();

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await player.setShuffleModeEnabled(
      shuffleMode != AudioServiceShuffleMode.none,
    );
    // The player emits no state event for a mode change; refresh the session.
    _broadcastState(player.playerState);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await player.setLoopMode(switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
      // just_audio has no group repeat; repeat the whole queue instead.
      AudioServiceRepeatMode.group => LoopMode.all,
    });
    _broadcastState(player.playerState);
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() => player.seekToNext();

  @override
  Future<void> skipToPrevious() => player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) =>
      player.seek(Duration.zero, index: index);

  void _broadcastState(PlayerState state) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (state.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 3],
        processingState: _audioProcessingState(state.processingState),
        playing: state.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: player.currentIndex,
        repeatMode: switch (player.loopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.one => AudioServiceRepeatMode.one,
          LoopMode.all => AudioServiceRepeatMode.all,
        },
        shuffleMode: player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  void _broadcastCurrentItem(int? index) {
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
  }

  AudioProcessingState _audioProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }
}

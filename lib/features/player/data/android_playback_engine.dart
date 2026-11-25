import 'package:alloy/features/player/data/audio_handler.dart';
import 'package:alloy/features/player/data/audio_service_playback_engine.dart';
import 'package:alloy/features/player/domain/playback_engine.dart';
import 'package:audio_service/audio_service.dart';

/// Android playback: just_audio behind audio_service's media session.
final class AndroidPlaybackEngine extends AudioServicePlaybackEngine {
  /// Creates an engine around [handler].
  new({required super.handler});

  /// Starts the audio service and returns an engine driving it.
  static Future<AndroidPlaybackEngine> connect({
    required TrackUriResolver resolveUri,
  }) async {
    final handler = await AudioService.init(
      builder: () => AlloyAudioHandler(resolveUri: resolveUri),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.dynamjobs.alloy.channel.audio',
        androidNotificationChannelName: 'Playback',
        androidNotificationOngoing: true,
      ),
    );
    return AndroidPlaybackEngine(handler: handler);
  }
}

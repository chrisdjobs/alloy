import 'package:alloy/features/player/data/audio_handler.dart';
import 'package:alloy/features/player/data/audio_service_playback_engine.dart';
import 'package:alloy/features/player/domain/playback_engine.dart';
import 'package:audio_service/audio_service.dart';

/// Linux playback: just_audio through media_kit, exposed over MPRIS.
///
/// Known limitation: `audio_service_mpris` 0.2.1 has no seek or volume
/// support, so desktop media keys can play, pause and skip but not seek.
final class LinuxPlaybackEngine extends AudioServicePlaybackEngine {
  /// Creates an engine around [handler].
  new({required super.handler});

  /// Starts the audio service and returns an engine driving it.
  ///
  /// The generated plugin registrant already installed the MPRIS platform
  /// interface, so this only needs to start the service.
  static Future<LinuxPlaybackEngine> connect({
    required TrackUriResolver resolveUri,
  }) async {
    final handler = await AudioService.init(
      builder: () => AlloyAudioHandler(resolveUri: resolveUri),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.dynamjobs.alloy.channel.audio',
        androidNotificationChannelName: 'Alloy',
      ),
    );
    return LinuxPlaybackEngine(handler: handler);
  }
}

import 'package:alloy/core/platform/audio_permission.dart';

/// [AudioPermission] with a configurable answer.
final class FakeAudioPermission implements AudioPermission {
  /// Status returned by [request].
  AudioPermissionStatus status = AudioPermissionStatus.granted;

  /// Number of [request] calls.
  int calls = 0;

  @override
  Future<AudioPermissionStatus> request() async {
    calls++;
    return status;
  }
}

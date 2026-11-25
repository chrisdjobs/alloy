import 'package:alloy/core/platform/audio_permission.dart';
import 'package:permission_handler/permission_handler.dart';

/// [AudioPermission] backed by `permission_handler` on Android.
final class PermissionHandlerAudioPermission implements AudioPermission {
  /// Creates the Android permission adapter.
  const new();

  @override
  Future<AudioPermissionStatus> request() async {
    final audio = await Permission.audio.request();
    if (audio.isGranted || audio.isLimited) {
      return AudioPermissionStatus.granted;
    }
    if (audio.isPermanentlyDenied) {
      return AudioPermissionStatus.permanentlyDenied;
    }

    // Below Android 13 there is no media audio permission; ask for the legacy
    // storage permission instead. On newer releases it reports denied.
    final storage = await Permission.storage.request();
    if (storage.isGranted || storage.isLimited) {
      return AudioPermissionStatus.granted;
    }
    if (storage.isPermanentlyDenied) {
      return AudioPermissionStatus.permanentlyDenied;
    }
    return AudioPermissionStatus.denied;
  }
}

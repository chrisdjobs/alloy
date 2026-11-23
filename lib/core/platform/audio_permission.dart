/// Result of asking for read access to the user's audio files.
enum AudioPermissionStatus {
  /// The app may read the library.
  granted,

  /// The user declined; the request can be repeated later.
  denied,

  /// The user declined permanently; only system settings can change it.
  permanentlyDenied,
}

/// Asks for read access to local audio files.
///
/// Android scoped storage needs a runtime permission; desktop returns
/// [AudioPermissionStatus.granted] because the folder picker grants access.
abstract interface class AudioPermission {
  /// Requests access and returns the resulting status.
  Future<AudioPermissionStatus> request();
}

/// Permission that is always granted, used on platforms without a runtime
/// audio permission.
final class GrantedAudioPermission implements AudioPermission {
  /// Creates a permission that never blocks.
  const new();

  @override
  Future<AudioPermissionStatus> request() async =>
      AudioPermissionStatus.granted;
}

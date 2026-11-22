/// Host platform the app is running on.
enum AppPlatform {
  /// Android, a first-class target.
  android,

  /// Linux desktop, a first-class target.
  linux,

  /// Any other platform. Kept working, but not tested yet.
  other,
}

/// Describes the host platform without leaking `dart:io`.
///
/// The rest of the app depends on this interface so platform checks stay in
/// one place and tests can provide a fake.
abstract class PlatformInfo {
  /// Creates a platform description.
  const new();

  /// The current platform.
  AppPlatform get platform;

  /// Whether the app runs on Android.
  bool get isAndroid => platform == AppPlatform.android;

  /// Whether the app runs on Linux.
  bool get isLinux => platform == AppPlatform.linux;
}

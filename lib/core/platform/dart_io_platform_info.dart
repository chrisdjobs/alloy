import 'dart:io';

import 'package:bars/core/platform/platform_info.dart';

/// [PlatformInfo] implementation backed by `dart:io`.
///
/// This is the only place allowed to read `Platform.isX`; wire it into the app
/// from bootstrap.
final class DartIoPlatformInfo extends PlatformInfo {
  /// Creates a platform description for the current host.
  const new();

  @override
  AppPlatform get platform {
    if (Platform.isAndroid) return AppPlatform.android;
    if (Platform.isLinux) return AppPlatform.linux;
    return AppPlatform.other;
  }
}

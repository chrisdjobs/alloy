import 'package:flutter/services.dart';

/// Switches the launcher icon on the host platform.
///
/// Android enables the `<activity-alias>` of the chosen preset; Linux updates
/// the icon of the running window. Other hosts ignore the choice.
abstract interface class AppIconSwitcher {
  /// Applies the icon registered as [id]; false when the host ignores it.
  Future<bool> setIcon(String id);
}

/// [AppIconSwitcher] for hosts without a launcher icon and for tests.
final class NoopAppIconSwitcher implements AppIconSwitcher {
  /// Creates the no-op switcher.
  const new();

  @override
  Future<bool> setIcon(String id) async => false;
}

/// [AppIconSwitcher] backed by the `com.dynamjobs.alloy/app_icon` channel.
final class MethodChannelAppIconSwitcher implements AppIconSwitcher {
  /// Creates the channel switcher.
  const new();

  static const _channel = MethodChannel('com.dynamjobs.alloy/app_icon');

  @override
  Future<bool> setIcon(String id) async {
    try {
      await _channel.invokeMethod<void>('setIcon', {'id': id});
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

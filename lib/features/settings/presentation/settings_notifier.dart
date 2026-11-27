import 'dart:async';

import 'package:alloy/core/logger.dart';
import 'package:alloy/core/platform/app_icon_switcher.dart';
import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/features/settings/domain/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

/// Repository behind the visual settings.
///
/// Hosts override it with a persisted one during bootstrap; the in-memory
/// fallback keeps widgets and tests working without storage.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return InMemorySettingsRepository();
});

/// Switches the launcher icon.
///
/// Bootstrap overrides it on Android and Linux; the no-op fallback keeps other
/// hosts and tests working.
final appIconSwitcherProvider = Provider<AppIconSwitcher>((ref) {
  return const NoopAppIconSwitcher();
});

/// Exposes [AppSettings] and persists every change.
@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() {
    final repository = ref.watch(settingsRepositoryProvider);
    final subscription = repository.changes.listen((settings) {
      state = settings;
    });
    ref.onDispose(() => unawaited(subscription.cancel()));
    return repository.current;
  }

  /// Persists [settings]; a failure is logged and leaves the state untouched.
  Future<void> replace(AppSettings settings) async {
    final failure = (await ref.read(settingsRepositoryProvider).save(settings))
        .failureOrNull;
    if (failure == null) return;
    Logger.error(
      failure.message ?? 'Could not save the settings',
      error: failure.cause,
      stackTrace: failure.stackTrace,
    );
  }

  /// Selects the destination the app opens on next launch.
  Future<void> setStartTab(AppTab tab) {
    return replace(state.copyWith(startTab: tab));
  }

  /// Stores the bottom bar order.
  Future<void> setNavOrder(List<AppTab> order) {
    return replace(state.copyWith(navOrder: order));
  }

  /// Switches between the icon packs.
  Future<void> setIconPack(AppIconPack pack) {
    return replace(state.copyWith(iconPack: pack));
  }

  /// Sets the accent color; null restores the design default.
  ///
  /// Picking a color also turns off [AppSettings.accentFromIcon].
  Future<void> setAccent(int? argb) {
    return replace(state.copyWith(accentArgb: argb, accentFromIcon: false));
  }

  /// Whether the accent follows the dominant color of the app icon.
  Future<void> setAccentFromIcon(bool enabled) {
    return replace(state.copyWith(accentFromIcon: enabled));
  }

  /// Selects the launcher icon preset and applies it to the host.
  Future<void> setAppIcon(String id) async {
    await replace(state.copyWith(appIconId: id));
    final applied = await ref.read(appIconSwitcherProvider).setIcon(id);
    if (!applied) {
      Logger.warning('The host could not apply the app icon $id');
    }
  }

  /// Sets the language override; null follows the system locale.
  Future<void> setLocale(String? code) {
    return replace(state.copyWith(localeCode: code));
  }
}

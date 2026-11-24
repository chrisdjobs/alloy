import 'package:bars/features/settings/domain/app_settings.dart';

/// Maps [AppSettings] to the key/value rows of the settings table and back.
///
/// Missing or unknown values decode to their defaults, so an older or newer
/// database never breaks the app.
abstract final class SettingsCodec {
  /// Row holding the accent color as ARGB.
  static const accentArgbKey = 'accent_argb';

  /// Row holding the [AppIconPack] name.
  static const iconPackKey = 'icon_pack';

  /// Row holding the comma-separated [AppTab] names of the bottom bar.
  static const navOrderKey = 'nav_order';

  /// Row holding the [AppTab] name the app opens on.
  static const startTabKey = 'start_tab';

  /// Row holding the language override.
  static const localeKey = 'locale';

  /// Rebuilds the settings stored in [entries].
  static AppSettings decode(Map<String, String> entries) {
    return AppSettings(
      accentArgb: int.tryParse(entries[accentArgbKey] ?? ''),
      iconPack:
          _decodeEnum(entries[iconPackKey], AppIconPack.values) ??
          AppIconPack.lucide,
      navOrder: _decodeNavOrder(entries[navOrderKey]),
      startTab:
          _decodeEnum(entries[startTabKey], AppTab.values) ?? AppTab.library,
      localeCode: _decodeLocale(entries[localeKey]),
    );
  }

  /// Rows to persist for [settings]; null values are simply absent.
  static Map<String, String> encode(AppSettings settings) {
    final accent = settings.accentArgb;
    final locale = settings.localeCode?.trim();

    return {
      if (accent != null) accentArgbKey: '$accent',
      iconPackKey: settings.iconPack.name,
      navOrderKey: settings.navOrder.map((tab) => tab.name).join(','),
      startTabKey: settings.startTab.name,
      if (locale != null && locale.isNotEmpty) localeKey: locale,
    };
  }

  static List<AppTab> _decodeNavOrder(String? value) {
    final ordered = <AppTab>[];
    for (final name in value?.split(',') ?? const <String>[]) {
      final tab = _decodeEnum(name, AppTab.values);
      if (tab != null && !ordered.contains(tab)) ordered.add(tab);
    }
    // A stored order that lost tabs (or predates one) keeps every destination.
    for (final tab in AppTab.values) {
      if (!ordered.contains(tab)) ordered.add(tab);
    }
    return ordered;
  }

  static String? _decodeLocale(String? value) {
    final locale = value?.trim();
    return locale == null || locale.isEmpty ? null : locale;
  }

  static T? _decodeEnum<T extends Enum>(String? value, List<T> values) {
    if (value == null) return null;
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    return null;
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Top-level destinations, in the order the router registers their branches.
enum AppTab {
  /// Home.
  home,

  /// Discover.
  discover,

  /// Library.
  library,

  /// Settings hub, shown as "Me".
  me,
}

/// Icon packs the user can switch between.
enum AppIconPack {
  /// Lucide outline icons, the default.
  lucide,

  /// The Material icon set.
  material,
}

/// Visual and behavioural preferences owned by the user.
///
/// Pure Dart on purpose: the settings feature stores and exposes them, while
/// the UI maps them to colors and widgets.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates the settings.
  // Freezed only recognizes the class name in redirecting factories.
  // ignore: unnecessary_type_name_in_constructor
  const factory AppSettings({
    /// Accent color as ARGB; null keeps the design default.
    int? accentArgb,

    /// Icon pack drawn by [AppIconPack].
    @Default(AppIconPack.lucide) AppIconPack iconPack,

    /// Visual order of the bottom bar.
    @Default([AppTab.home, AppTab.discover, AppTab.library, AppTab.me])
    List<AppTab> navOrder,

    /// Destination the app opens on.
    @Default(AppTab.library) AppTab startTab,

    /// Language override; null follows the system locale.
    String? localeCode,
  }) = _AppSettings;
}

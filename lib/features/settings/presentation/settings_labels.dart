import 'package:bars/features/settings/domain/app_settings.dart';
import 'package:bars/l10n/app_localizations.dart';

/// Localized name of an icon [pack].
String iconPackName(AppLocalizations l10n, AppIconPack pack) {
  return switch (pack) {
    AppIconPack.lucide => l10n.iconPackLucide,
    AppIconPack.material => l10n.iconPackMaterial,
  };
}

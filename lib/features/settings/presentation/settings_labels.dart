import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/l10n/app_localizations.dart';

/// Localized name of the language override [code]; null follows the system.
String languageName(AppLocalizations l10n, String? code) {
  return switch (code) {
    'en' => l10n.languageEnglish,
    'es' => l10n.languageSpanish,
    _ => l10n.systemLanguage,
  };
}

/// Localized name of an icon [pack].
String iconPackName(AppLocalizations l10n, AppIconPack pack) {
  return switch (pack) {
    AppIconPack.lucide => l10n.iconPackLucide,
    AppIconPack.material => l10n.iconPackMaterial,
  };
}

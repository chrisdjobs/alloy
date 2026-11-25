import 'dart:async';

import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/features/settings/presentation/widgets/settings_sub_screen.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Language override; the first option follows the phone's locale.
class LanguageScreen extends ConsumerWidget {
  /// Creates the language screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final options = <(String?, String)>[
      (null, l10n.systemLanguage),
      ('en', l10n.languageEnglish),
      ('es', l10n.languageSpanish),
    ];

    return SettingsSubScreen(
      title: l10n.languageTitle,
      children: [
        const SizedBox(height: AppSpacing.sm),
        for (final (code, label) in options)
          _LanguageRow(
            label: label,
            selected: settings.localeCode == code,
            onTap: () => unawaited(notifier.setLocale(code)),
          ),
      ],
    );
  }
}

/// Option of the language list; the active one carries a check.
class _LanguageRow extends StatelessWidget {
  const new({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.title)),
            if (selected)
              Icon(
                context.icons.check,
                size: AppSizing.settingsRowIcon,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

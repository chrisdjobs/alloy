import 'package:alloy/features/settings/presentation/settings_labels.dart';
import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/features/settings/presentation/widgets/settings_sub_screen.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Appearance settings hub.
///
/// Only the general look exists for now; the player, mini-player and widget
/// groups of the reference are not built.
class AppearanceScreen extends ConsumerWidget {
  /// Creates the appearance hub.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return SettingsSubScreen(
      title: l10n.appearanceTitle,
      children: [
        SettingsRow(
          icon: context.icons.appearance,
          title: l10n.generalTitle,
          subtitle: l10n.appearanceSummary(
            iconPackName(l10n, settings.iconPack),
          ),
          onTap: () => context.push('/settings/appearance/general'),
        ),
      ],
    );
  }
}

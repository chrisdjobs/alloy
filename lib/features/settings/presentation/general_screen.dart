import 'dart:async';

import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/features/settings/presentation/widgets/settings_sub_screen.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/accent_palette.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/widgets/app_choice_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// General appearance: accent color and icon pack.
class GeneralScreen extends ConsumerWidget {
  /// Creates the general appearance screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final accent = settings.accentArgb ?? AppAccents.fallback;

    return SettingsSubScreen(
      title: l10n.generalTitle,
      children: [
        SettingsSection(title: l10n.accentColor),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final argb in AppAccents.palette)
                _AccentSwatch(
                  argb: argb,
                  selected: argb == accent,
                  onTap: () => unawaited(notifier.setAccent(argb)),
                ),
            ],
          ),
        ),
        SettingsSection(title: l10n.iconsSection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppChoiceChip(
                label: l10n.iconPackMaterial,
                selected: settings.iconPack == AppIconPack.material,
                onTap: () =>
                    unawaited(notifier.setIconPack(AppIconPack.material)),
              ),
              AppChoiceChip(
                label: l10n.iconPackLucide,
                selected: settings.iconPack == AppIconPack.lucide,
                onTap: () =>
                    unawaited(notifier.setIconPack(AppIconPack.lucide)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Round accent color; the selected one carries a ring.
class _AccentSwatch extends StatelessWidget {
  const new({required this.argb, required this.selected, required this.onTap});

  final int argb;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkResponse(
        onTap: onTap,
        radius: AppSizing.accentSwatchBox / 2,
        child: SizedBox.square(
          dimension: AppSizing.accentSwatchBox,
          child: Center(
            child: Container(
              width: AppSizing.accentSwatchBox,
              height: AppSizing.accentSwatchBox,
              padding: const EdgeInsets.all(AppSizing.accentSwatchRing),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.textPrimary : Colors.transparent,
                  width: AppSizing.accentSwatchRing,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(argb),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

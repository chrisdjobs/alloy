import 'dart:async';

import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/features/settings/presentation/widgets/settings_sub_screen.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/accent_palette.dart';
import 'package:alloy/shared/design/gradient_presets.dart';
import 'package:alloy/shared/design/gradient_presets_provider.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/widgets/app_choice_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// General appearance: app icon, accent color and icon pack.
class GeneralScreen extends ConsumerWidget {
  /// Creates the general appearance screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final preset = ref.watch(activeGradientPresetProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final accent = settings.accentArgb ?? AppAccents.fallback;

    return SettingsSubScreen(
      title: l10n.generalTitle,
      children: [
        SettingsSection(title: l10n.appIconSection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.lg,
            children: [
              for (final option in AppGradientPresets.all)
                _AppIconTile(
                  preset: option,
                  label: _iconName(l10n, option),
                  selected: option.id == preset.id,
                  onTap: () => unawaited(notifier.setAppIcon(option.id)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            0,
          ),
          child: Text(
            l10n.appIconHint,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
        SettingsSection(title: l10n.accentColor),
        _AccentFromIconRow(
          title: l10n.accentFromIcon,
          subtitle: l10n.accentFromIconSubtitle,
          value: settings.accentFromIcon,
          onChanged: (value) => unawaited(notifier.setAccentFromIcon(value)),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final argb in AppAccents.palette)
                _AccentSwatch(
                  argb: argb,
                  selected: !settings.accentFromIcon && argb == accent,
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

/// Localized name of [preset] in the app icon picker.
String _iconName(AppLocalizations l10n, GradientPreset preset) {
  return switch (preset.id) {
    'default' => l10n.iconNameDefault,
    'cpunk' => l10n.iconNameCpunk,
    _ => preset.name,
  };
}

/// Launcher icon option; the selected one carries a white ring.
class _AppIconTile extends StatelessWidget {
  const new({
    required this.preset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final GradientPreset preset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pixels =
        AppSizing.appIconTile * MediaQuery.devicePixelRatioOf(context);

    return Semantics(
      button: true,
      selected: selected,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizing.appIconTile,
              height: AppSizing.appIconTile,
              padding: const EdgeInsets.all(AppSizing.appIconRing),
              decoration: BoxDecoration(
                borderRadius: AppRadii.cardLarge,
                border: Border.all(
                  color: selected ? AppColors.textPrimary : Colors.transparent,
                  width: AppSizing.appIconRing,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppRadii.lg - AppSizing.appIconRing,
                ),
                child: Image.asset(
                  preset.iconAsset,
                  fit: BoxFit.cover,
                  cacheWidth: pixels.round(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle that makes the accent follow the app icon's dominant color.
class _AccentFromIconRow extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.onAccent,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.outline,
          ),
        ],
      ),
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

import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/settings/presentation/settings_labels.dart';
import 'package:bars/features/settings/presentation/settings_notifier.dart';
import 'package:bars/features/settings/presentation/widgets/settings_sub_screen.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/gradient_presets_provider.dart';
import 'package:bars/shared/design/gradients.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:bars/shared/widgets/preset_glow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Settings hub, reached from the "Me" destination.
///
/// The library counts come from the router, so this feature only imports the
/// library's domain.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings hub.
  const new({required this.tracks, super.key});

  /// Library tracks and their load state.
  final AsyncValue<List<Track>> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final preset = ref.watch(activeGradientPresetProvider);
    final library = tracks.value;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.xl,
          bottom: AppSpacing.xl,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _IdentityCard(
              title: l10n.appTitle,
              initial: l10n.appTitle.substring(0, 1),
              glow: preset.glow,
              stats: library == null
                  ? null
                  : l10n.libraryStats(
                      l10n.trackCount(library.length),
                      l10n.albumCount(_albums(library)),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SettingsRow(
            icon: context.icons.appearance,
            title: l10n.appearanceTitle,
            subtitle: l10n.appearanceSummary(
              iconPackName(l10n, settings.iconPack),
            ),
            onTap: () => context.push('/settings/appearance'),
          ),
          SettingsRow(
            icon: context.icons.language,
            title: l10n.languageTitle,
            subtitle: languageName(l10n, settings.localeCode),
            onTap: () => context.push('/settings/language'),
          ),
          SettingsRow(
            icon: context.icons.folder,
            title: l10n.musicAndStorageTitle,
            subtitle: l10n.musicFoldersSummary(
              l10n.trackCount(library?.length ?? 0),
            ),
            onTap: () => context.push('/settings/storage'),
          ),
        ],
      ),
    );
  }
}

int _albums(List<Track> tracks) {
  return tracks.map((track) => track.album).whereType<String>().toSet().length;
}

/// Identity card: gradient monogram, app name and the library counts.
///
/// The preset glow is painted inside the card and clipped to its radius, so
/// the card itself carries the wash instead of sitting on a page-level glow.
class _IdentityCard extends StatelessWidget {
  const new({
    required this.title,
    required this.initial,
    required this.glow,
    this.stats,
  });

  final String title;
  final String initial;
  final List<RadialGradient> glow;
  final String? stats;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: AppRadii.cardLarge,
      child: ColoredBox(
        color: AppColors.surface,
        child: Stack(
          children: [
            Positioned.fill(child: PresetGlow(layers: glow, fadeOut: false)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: AppSizing.profileAvatar,
                    height: AppSizing.profileAvatar,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.accent(accent),
                    ),
                    child: Text(
                      initial,
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: AppTextStyles.playerTitle),
                        if (stats case final stats?) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            stats,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

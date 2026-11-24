import 'package:bars/features/library/domain/track_sort.dart';
import 'package:bars/features/library/presentation/library_view_options.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:bars/shared/widgets/app_choice_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom sheet with the options of the library list: order and row details.
class LibraryOptionsSheet extends ConsumerWidget {
  /// Creates the sheet.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(libraryViewOptionsProvider);
    final notifier = ref.read(libraryViewOptionsProvider.notifier);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: AppSizing.sheetHandleWidth,
                height: AppSizing.sheetHandleHeight,
                decoration: const BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: AppRadii.pill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.libraryTracks, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.sortBy,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final option in _options(l10n, context.icons))
                  AppChoiceChip(
                    label: option.label,
                    icon: option.icon,
                    selected: options.sort == option.sort,
                    onTap: () => notifier.setSort(option.sort),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.showDuration,
                    style: AppTextStyles.trackTitle,
                  ),
                ),
                Switch(
                  value: options.showDuration,
                  onChanged: notifier.setShowDuration,
                  activeThumbColor: AppColors.onAccent,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

typedef _SortOption = ({TrackSort sort, String label, IconData icon});

List<_SortOption> _options(AppLocalizations l10n, AppIconSet icons) {
  return [
    (
      sort: TrackSort.titleAscending,
      label: l10n.sortTitleAscending,
      icon: icons.sort,
    ),
    (
      sort: TrackSort.titleDescending,
      label: l10n.sortTitleDescending,
      icon: icons.sort,
    ),
    (
      sort: TrackSort.recentlyAdded,
      label: l10n.recentlyAdded,
      icon: icons.calendar,
    ),
    (
      sort: TrackSort.oldestAdded,
      label: l10n.sortOldestAdded,
      icon: icons.calendar,
    ),
    (sort: TrackSort.album, label: l10n.sortAlbum, icon: icons.sort),
    (sort: TrackSort.artist, label: l10n.sortArtist, icon: icons.sort),
    (sort: TrackSort.duration, label: l10n.sortDuration, icon: icons.duration),
  ];
}

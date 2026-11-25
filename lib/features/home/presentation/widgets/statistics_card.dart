import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Surface card with four library totals: tracks, albums, artists and length.
class StatisticsCard extends StatelessWidget {
  /// Creates the card for [statistics].
  const new({required this.statistics, super.key});

  /// Totals to show.
  final HomeStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              _StatTile(
                value: '${statistics.trackCount}',
                label: l10n.libraryTracks,
              ),
              _StatTile(
                value: '${statistics.albumCount}',
                label: l10n.libraryAlbums,
              ),
              _StatTile(
                value: '${statistics.artistCount}',
                label: l10n.libraryArtists,
              ),
              _StatTile(
                value: _length(l10n, statistics.totalDuration),
                label: l10n.totalLength,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _length(AppLocalizations l10n, Duration duration) {
    if (duration.inHours > 0) return l10n.durationHours(duration.inHours);
    return l10n.durationMinutes(duration.inMinutes);
  }
}

class _StatTile extends StatelessWidget {
  const new({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.trackArtist.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

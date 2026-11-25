import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Surface card with the library totals and the lyrics breakdown.
class StatisticsCard extends StatelessWidget {
  /// Creates the card for [statistics] and [lyrics].
  const new({required this.statistics, required this.lyrics, super.key});

  /// Totals to show.
  final HomeStatistics statistics;

  /// Lyrics availability to show.
  final LyricsBreakdown lyrics;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    value: _compactDuration(l10n, statistics.totalDuration),
                    label: l10n.totalLength,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // The chevron marks the row that will open the lyrics screen
              // once lyrics exist; until then it is decoration only.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.lyrics,
                      style: AppTextStyles.trackTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    context.icons.forward,
                    size: AppSizing.chipIcon,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _LyricsBar(lyrics: lyrics),
              const SizedBox(height: AppSpacing.md),
              _LyricsLegend(lyrics: lyrics),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented bar with one segment per lyrics kind.
class _LyricsBar extends StatelessWidget {
  const new({required this.lyrics});

  final LyricsBreakdown lyrics;

  @override
  Widget build(BuildContext context) {
    final colors = _lyricsColors(context);
    final total = lyrics.total;
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: AppRadii.pill,
      child: SizedBox(
        height: AppSizing.lyricsBarHeight,
        child: Row(
          // Stretch gives every segment the full height of the bar; a plain
          // ColoredBox would collapse under the loose constraints.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSizing.activityBarGap,
          children: [
            for (final (count, color) in [
              (lyrics.synced, colors.synced),
              (lyrics.textOnly, colors.textOnly),
              (lyrics.none, colors.none),
            ])
              if (count > 0)
                Expanded(
                  flex: count,
                  child: ColoredBox(color: color),
                ),
          ],
        ),
      ),
    );
  }
}

/// Legend rows under the lyrics bar: dot, label and "count · percent".
class _LyricsLegend extends StatelessWidget {
  const new({required this.lyrics});

  final LyricsBreakdown lyrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = _lyricsColors(context);

    return Column(
      children: [
        for (final (count, color, label) in [
          (lyrics.synced, colors.synced, l10n.lyricsSynced),
          (lyrics.textOnly, colors.textOnly, l10n.lyricsTextOnly),
          (lyrics.none, colors.none, l10n.lyricsNone),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: AppSizing.lyricsDot),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  l10n.lyricsStat(count, _percent(count, lyrics.total)),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  int _percent(int count, int total) =>
      total == 0 ? 0 : (count * 100 / total).round();
}

/// Whole hours as "26 h", or "42 min" below one hour.
///
/// The Length tile is narrow, and the references show whole hours there.
String _compactDuration(AppLocalizations l10n, Duration duration) {
  if (duration.inHours >= 1) return l10n.durationHours(duration.inHours);
  return l10n.durationMinutes(duration.inMinutes);
}

/// Colors of the lyrics bar and its legend, derived from the active accent.
({Color synced, Color textOnly, Color none}) _lyricsColors(
  BuildContext context,
) {
  final accent = Theme.of(context).colorScheme.primary;
  // Halfway to the surface keeps "Text only" readable but clearly dimmer
  // than the synced segment, as in the visual references.
  return (
    synced: accent,
    textOnly: Color.lerp(accent, AppColors.surface, 0.5)!,
    none: AppColors.outline,
  );
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

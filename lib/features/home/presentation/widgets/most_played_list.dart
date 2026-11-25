import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/features/home/presentation/home_callbacks.dart';
import 'package:alloy/features/home/presentation/widgets/media_carousel.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/widgets/app_choice_chip.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// Ranked list of the most played tracks with a week/month toggle.
///
/// Shows the first five entries until "See all" expands the list.
class MostPlayedList extends StatefulWidget {
  /// Creates the list; tapping a row plays the ranking from that track.
  const new({
    required this.entries,
    required this.period,
    required this.onPeriodChanged,
    required this.onPlay,
    super.key,
  });

  /// Ranked entries, best first.
  final List<MostPlayedEntry> entries;

  /// Active statistics window.
  final HomePeriod period;

  /// Switches the window.
  final OnPeriodChanged onPeriodChanged;

  /// Playback callback.
  final PlayTracksCallback onPlay;

  @override
  State<MostPlayedList> createState() => _MostPlayedListState();
}

class _MostPlayedListState extends State<MostPlayedList> {
  static const int _collapsedCount = 5;

  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = widget.entries;
    if (entries.isEmpty) return const SizedBox.shrink();
    final tracks = [for (final entry in entries) entry.track];
    final visible = _expanded
        ? entries
        : entries.take(_collapsedCount).toList(growable: false);

    return Column(
      children: [
        SectionHeader(
          title: l10n.mostPlayed,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppChoiceChip(
                label: l10n.week,
                selected: widget.period == HomePeriod.week,
                onTap: () => widget.onPeriodChanged(HomePeriod.week),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppChoiceChip(
                label: l10n.month,
                selected: widget.period == HomePeriod.month,
                onTap: () => widget.onPeriodChanged(HomePeriod.month),
              ),
            ],
          ),
        ),
        for (var i = 0; i < visible.length; i++)
          _MostPlayedRow(
            rank: i + 1,
            entry: visible[i],
            onTap: () => widget.onPlay(tracks, i),
          ),
        if (!_expanded && entries.length > _collapsedCount)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _expanded = true),
              child: Text(
                l10n.seeAll,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MostPlayedRow extends StatelessWidget {
  const new({required this.rank, required this.entry, required this.onTap});

  final int rank;
  final MostPlayedEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final track = entry.track;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppSpacing.xl,
              child: Text(
                '$rank',
                style: AppTextStyles.trackTitle.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ArtworkImage(artworkRef: track.artworkRef),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.trackTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (track.artist != null)
                    Text(
                      track.artist!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.trackArtist.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.playCount(entry.playCount),
              style: AppTextStyles.trackArtist.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

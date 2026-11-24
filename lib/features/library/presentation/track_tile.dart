import 'package:bars/features/library/domain/track.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// One row of the library list.
///
/// [leading] is the artwork slot; it defaults to the track's cover and falls
/// back to the shared no-cover tile.
class TrackTile extends StatelessWidget {
  /// Creates a row for [track] that calls [onTap] when activated.
  const new({
    required this.track,
    required this.onTap,
    this.leading,
    super.key,
  });

  /// Track shown in the row.
  final Track track;

  /// Opens the track in the player.
  final VoidCallback onTap;

  /// Cover slot; defaults to the track's [ArtworkImage].
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          height: AppSizing.trackRow,
          child: Row(
            children: [
              leading ?? ArtworkImage(artworkRef: track.artworkRef),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
              PopupMenuButton<_TrackAction>(
                icon: const Icon(AppIcons.more),
                onSelected: (_) => onTap(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _TrackAction.play,
                    child: Row(
                      children: [
                        Icon(AppIcons.play, size: 18, color: accent),
                        const SizedBox(width: AppSpacing.sm),
                        Text(l10n.play),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TrackAction { play }

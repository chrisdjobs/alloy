import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/library/presentation/track_tile.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Plays [tracks] starting at [index].
typedef PlayTracksCallback = void Function(List<Track> tracks, int index);

/// Plays [tracks] in random order.
typedef ShuffleTracksCallback = void Function(List<Track> tracks);

/// Track list shared by the library and its album and artist details.
///
/// The caller orders [tracks]; the list only adds the shuffle-all row on top.
class LibraryTrackList extends StatelessWidget {
  /// Creates the list.
  const new({
    required this.tracks,
    required this.onPlay,
    required this.onShuffleAll,
    this.showDuration = false,
    this.currentTrackId,
    this.isPlaying = false,
    super.key,
  });

  /// Tracks to draw, already ordered.
  final List<Track> tracks;

  /// Opens a track from the list.
  final PlayTracksCallback onPlay;

  /// Starts [tracks] in shuffle mode.
  final ShuffleTracksCallback onShuffleAll;

  /// Whether every row shows the track length.
  final bool showDuration;

  /// Id of the track loaded in the player; its row marks itself.
  final String? currentTrackId;

  /// Whether the loaded track is playing.
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: tracks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ShuffleAllRow(onTap: () => onShuffleAll(tracks));
        }
        final trackIndex = index - 1;
        final track = tracks[trackIndex];
        return TrackTile(
          track: track,
          showDuration: showDuration,
          isCurrent: track.id == currentTrackId,
          isPlaying: isPlaying,
          onTap: () => onPlay(tracks, trackIndex),
        );
      },
    );
  }
}

class _ShuffleAllRow extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Row(
            children: [
              Icon(
                context.icons.shuffle,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xl),
              Text(
                l10n.shuffleAll.toUpperCase(),
                style: AppTextStyles.action.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

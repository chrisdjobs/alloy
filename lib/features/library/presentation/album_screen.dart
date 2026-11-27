import 'package:alloy/features/library/domain/album.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/library/domain/track_sort.dart';
import 'package:alloy/features/library/presentation/library_track_list.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/alloy_page_header.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// Detail of one album: its cover, title, artist and tracks.
class AlbumScreen extends StatelessWidget {
  /// Creates the detail for [album].
  const new({
    required this.album,
    required this.tracks,
    required this.onBack,
    required this.onPlay,
    required this.onShuffleAll,
    this.currentTrackId,
    this.isPlaying = false,
    super.key,
  });

  /// Album shown by the screen.
  final Album album;

  /// Whole library; the screen keeps the album's tracks.
  final List<Track> tracks;

  /// Returns to the library tabs.
  final VoidCallback onBack;

  /// Opens a track from the list.
  final PlayTracksCallback onPlay;

  /// Starts the album's tracks in shuffle mode.
  final ShuffleTracksCallback onShuffleAll;

  /// Id of the track loaded in the player; its row marks itself.
  final String? currentTrackId;

  /// Whether the loaded track is playing.
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordered = sortTracks(albumTracks(tracks, album), TrackSort.album);
    final subtitle = [
      if (album.artist != null) album.artist!,
      l10n.trackCount(album.trackCount),
    ].join(' · ');

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AlloyPageHeader(
            title: album.title,
            leading: IconButton(
              onPressed: onBack,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Icon(context.icons.back),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: [
                ArtworkImage(artworkRef: album.artworkRef, size: 120),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.trackArtist.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ordered.isEmpty
                ? Center(
                    child: Text(
                      l10n.noTracksFound,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : LibraryTrackList(
                    tracks: ordered,
                    onPlay: onPlay,
                    onShuffleAll: onShuffleAll,
                    currentTrackId: currentTrackId,
                    isPlaying: isPlaying,
                  ),
          ),
        ],
      ),
    );
  }
}

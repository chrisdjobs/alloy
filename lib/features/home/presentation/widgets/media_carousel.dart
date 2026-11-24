import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/features/home/domain/home_sections.dart';
import 'package:bars/features/home/presentation/home_callbacks.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// Uppercase title above a Home section.
class SectionHeader extends StatelessWidget {
  /// Creates the header for [title].
  const new({required this.title, super.key});

  /// Section title, drawn in uppercase.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Text(
        title.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.sectionHeader.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Horizontal list of tracks with cover, title and artist.
class TrackCarousel extends StatelessWidget {
  /// Creates the carousel; tapping a card plays [tracks] at that position.
  const new({required this.tracks, required this.onPlay, super.key});

  /// Tracks in display order.
  final List<Track> tracks;

  /// Playback callback.
  final PlayTracksCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizing.homeCarouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: tracks.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final track = tracks[index];
          return _MediaCard(
            artworkRef: track.artworkRef,
            title: track.title,
            subtitle: track.artist,
            onTap: () => onPlay(tracks, index),
          );
        },
      ),
    );
  }
}

/// Horizontal list of albums with cover, title and artist.
class AlbumCarousel extends StatelessWidget {
  /// Creates the carousel; tapping a card plays the album.
  const new({required this.albums, required this.onPlay, super.key});

  /// Albums in display order.
  final List<HomeAlbum> albums;

  /// Playback callback.
  final PlayAlbumCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizing.homeCarouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: albums.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final album = albums[index];
          return _MediaCard(
            artworkRef: album.artworkRef,
            title: album.title,
            subtitle: album.artist,
            onTap: () => onPlay(album),
          );
        },
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  const new({
    required this.artworkRef,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ArtworkRef? artworkRef;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizing.homeCarouselCover,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.artwork,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtworkImage(
              artworkRef: artworkRef,
              size: AppSizing.homeCarouselCover,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.trackTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.trackArtist.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:alloy/features/library/domain/album.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// Grid of the albums in the library.
class AlbumGrid extends StatelessWidget {
  /// Creates the grid.
  const new({
    required this.albums,
    required this.onOpen,
    this.currentAlbumId,
    super.key,
  });

  /// Albums to draw, already ordered.
  final List<Album> albums;

  /// Opens the detail of an album.
  final ValueChanged<Album> onOpen;

  /// Id of the album of the loaded track, when known.
  final String? currentAlbumId;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 232,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.lg,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return LayoutBuilder(
          builder: (context, constraints) => _AlbumTile(
            album: album,
            coverSize: constraints.maxWidth,
            current: album.id == currentAlbumId,
            onTap: () => onOpen(album),
          ),
        );
      },
    );
  }
}

class _AlbumTile extends StatelessWidget {
  const new({
    required this.album,
    required this.coverSize,
    required this.current,
    required this.onTap,
  });

  final Album album;
  final double coverSize;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtworkImage(artworkRef: album.artworkRef, size: coverSize),
          const SizedBox(height: AppSpacing.sm),
          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.trackTitle.copyWith(
              color: current ? accent : AppColors.textPrimary,
            ),
          ),
          if (album.artist != null)
            Text(
              album.artist!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.trackArtist.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          Text(
            l10n.trackCount(album.trackCount),
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

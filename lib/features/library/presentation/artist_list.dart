import 'package:alloy/features/library/domain/artist.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// List of the artists in the library.
class ArtistList extends StatelessWidget {
  /// Creates the list.
  const new({
    required this.artists,
    required this.onOpen,
    this.currentArtistId,
    super.key,
  });

  /// Artists to draw, already ordered.
  final List<Artist> artists;

  /// Opens the detail of an artist.
  final ValueChanged<Artist> onOpen;

  /// Id of the artist of the loaded track, when known.
  final String? currentArtistId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return _ArtistTile(
          artist: artist,
          current: artist.id == currentArtistId,
          onTap: () => onOpen(artist),
        );
      },
    );
  }
}

class _ArtistTile extends StatelessWidget {
  const new({required this.artist, required this.current, required this.onTap});

  final Artist artist;
  final bool current;
  final VoidCallback onTap;

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
              ArtworkImage(artworkRef: artist.artworkRef),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.trackTitle.copyWith(
                        color: current ? accent : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.trackCount(artist.trackCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.trackArtist.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(context.icons.forward, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

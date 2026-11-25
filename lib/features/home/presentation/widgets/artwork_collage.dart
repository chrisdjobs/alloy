import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// Square 2x2 collage of covers, as the mix cards of the visual references.
///
/// Fewer than four covers repeat the ones available; an empty list falls back
/// to the single no-cover tile.
class ArtworkCollage extends StatelessWidget {
  /// Creates a collage of [size] logical pixels from [artworks].
  const new({required this.artworks, required this.size, super.key});

  /// Covers to arrange; the first four distinct ones are used.
  final List<ArtworkRef> artworks;

  /// Width and height of the whole collage.
  final double size;

  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) return ArtworkImage(artworkRef: null, size: size);

    final tiles = _fill(artworks);
    final tileSize = (size - AppSizing.collageGap) / 2;

    return ClipRRect(
      borderRadius: AppRadii.artwork,
      child: SizedBox.square(
        dimension: size,
        child: Column(
          children: [
            Row(
              children: [
                _tile(tiles[0], tileSize),
                _gap,
                _tile(tiles[1], tileSize),
              ],
            ),
            _gap,
            Row(
              children: [
                _tile(tiles[2], tileSize),
                _gap,
                _tile(tiles[3], tileSize),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Expands [artworks] to exactly four covers by cycling what is available.
  List<ArtworkRef> _fill(List<ArtworkRef> artworks) {
    final tiles = <ArtworkRef>[];
    for (var i = 0; tiles.length < 4; i++) {
      tiles.add(
        i < artworks.length ? artworks[i] : artworks[i % artworks.length],
      );
    }
    return tiles;
  }

  Widget _tile(ArtworkRef artwork, double size) {
    return ArtworkImage(
      artworkRef: artwork,
      size: size,
      borderRadius: AppRadii.collageTile,
    );
  }

  Widget get _gap => const SizedBox.square(dimension: AppSizing.collageGap);
}

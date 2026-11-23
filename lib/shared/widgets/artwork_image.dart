import 'package:bars/core/artwork/artwork_providers.dart';
import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/no_cover_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Rounded cover image used everywhere a track shows artwork.
///
/// Rendering falls back to the shared [NoCoverTile] while a cover loads, when
/// the track has none, or when extraction fails: a missing cover is a normal
/// state, not an error screen.
class ArtworkImage extends ConsumerWidget {
  /// Shows the cover behind [artworkRef] at [size] logical pixels.
  const new({
    required this.artworkRef,
    this.size = AppSizing.coverRow,
    this.borderRadius = AppRadii.artwork,
    super.key,
  });

  /// Cover to show; null renders the no-cover tile.
  final ArtworkRef? artworkRef;

  /// Width and height of the square.
  final double size;

  /// Corner radius of the tile.
  final BorderRadius borderRadius;

  /// Above this size the large cache variant is used.
  static const double _largeThreshold = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reference = artworkRef;
    final visual = reference == null
        ? null
        : ref
              .watch(
                artworkVisualProvider((
                  artworkRef: reference,
                  size: size > _largeThreshold
                      ? ArtworkSize.large
                      : ArtworkSize.small,
                )),
              )
              .value;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox.square(
          dimension: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: visual == null
                ? NoCoverTile(key: const ValueKey('no-cover'), size: size)
                : Image.memory(
                    visual.cover,
                    key: ValueKey(visual.cover),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                        .round(),
                    errorBuilder: (context, error, stackTrace) =>
                        NoCoverTile(size: size),
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:bars/core/artwork/artwork_providers.dart';
import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Cover-derived background for a surface.
///
/// A tiny cover that was blurred once by the artwork pipeline is scaled up, so
/// nothing is filtered while lists scroll. Multiplying it with its dominant
/// color keeps every pixel at most as bright as the color that was darkened
/// for text contrast; the scrim darkens it further.
class CoverBackdrop extends ConsumerWidget {
  /// Renders the backdrop for [artworkRef], or [fallback] without a cover.
  const new({required this.artworkRef, required this.fallback, super.key});

  /// Cover to derive the background from; null shows [fallback].
  final ArtworkRef? artworkRef;

  /// Accent-tinted placeholder shown when there is no cover.
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reference = artworkRef;
    final visual = reference == null
        ? null
        : ref
              .watch(
                artworkVisualProvider((
                  artworkRef: reference,
                  size: ArtworkSize.small,
                )),
              )
              .value;
    if (visual == null) return fallback;

    final color = Color(visual.backdropColorArgb);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: color),
        ExcludeSemantics(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.multiply),
            child: Image.memory(
              visual.backdrop,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
            ),
          ),
        ),
        const ColoredBox(color: AppColors.backdropScrim),
      ],
    );
  }
}

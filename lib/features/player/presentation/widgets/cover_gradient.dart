import 'package:alloy/core/artwork/artwork_providers.dart';
import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/artwork/artwork_visual.dart';
import 'package:alloy/shared/design/cover_colors.dart';
import 'package:alloy/shared/design/gradients.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Vertical cover-derived gradient behind the now-playing screen.
///
/// It cross-fades when the track changes. Without a cover the accent is
/// darkened with the same contrast rule, so text stays readable.
class CoverGradient extends ConsumerWidget {
  /// Renders the gradient for [artworkRef]'s dominant color.
  const new({required this.artworkRef, super.key});

  /// Cover whose color shapes the gradient; null uses the accent.
  final ArtworkRef? artworkRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reference = artworkRef;
    final visual = reference == null
        ? null
        : ref
              .watch(
                artworkVisualProvider((
                  artworkRef: reference,
                  size: ArtworkSize.large,
                )),
              )
              .value;
    final color = visual == null
        ? Color(CoverColors.backdropFor(AppColors.accent.toARGB32()))
        : Color(visual.backdropColorArgb);

    return AnimatedSwitcher(
      duration: AppDurations.gradientFade,
      child: DecoratedBox(
        key: ValueKey(color),
        decoration: BoxDecoration(gradient: AppGradients.coverFade(color)),
        child: const SizedBox.expand(),
      ),
    );
  }
}

import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/features/home/presentation/home_callbacks.dart';
import 'package:alloy/features/home/presentation/widgets/artwork_collage.dart';
import 'package:alloy/features/home/presentation/widgets/media_carousel.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Horizontal list of generated mixes with a cover collage, title and
/// description.
class MixCarousel extends StatelessWidget {
  /// Creates the carousel; tapping a card plays [mixes] at that position.
  const new({required this.mixes, required this.onPlay, super.key});

  /// Mixes in display order.
  final List<HomeMix> mixes;

  /// Playback callback.
  final PlayMixCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: AppSizing.homeMixCarouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: mixes.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final mix = mixes[index];
          return MediaCard(
            cover: ArtworkCollage(
              artworks: mix.artworks,
              size: AppSizing.homeCarouselCover,
            ),
            title: _title(l10n, mix.kind),
            subtitle: _subtitle(l10n, mix.kind),
            subtitleMaxLines: 2,
            onTap: () => onPlay(mix),
          );
        },
      ),
    );
  }

  String _title(AppLocalizations l10n, HomeMixKind kind) => switch (kind) {
    HomeMixKind.onRotation => l10n.mixOnRotationTitle,
    HomeMixKind.deepCuts => l10n.mixDeepCutsTitle,
  };

  String _subtitle(AppLocalizations l10n, HomeMixKind kind) => switch (kind) {
    HomeMixKind.onRotation => l10n.mixOnRotationSubtitle,
    HomeMixKind.deepCuts => l10n.mixDeepCutsSubtitle,
  };
}

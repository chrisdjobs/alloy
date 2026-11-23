import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Neutral fallback shown wherever a track has no cover art.
///
/// This is a real UI state, not an undesigned asset, so it is deliberately
/// not a `TbdPlaceholder`: a dark rounded tile with a muted music-note icon.
class NoCoverTile extends StatelessWidget {
  /// Creates a tile of [size] logical pixels.
  const new({this.size = AppSizing.coverRow, super.key});

  /// Width and height of the square tile.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadii.artwork,
        ),
        alignment: Alignment.center,
        child: Icon(
          AppIcons.track,
          size: size * 0.42,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

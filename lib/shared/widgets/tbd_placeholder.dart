import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder for assets that are not designed yet.
///
/// Shows `TBD` inside a muted rounded container. Use it for the logo,
/// illustrations and custom icons instead of inventing temporary brand assets.
class TbdPlaceholder extends StatelessWidget {
  /// Creates a placeholder, optionally constrained by [width] and [height].
  const new({this.width, this.height, this.label = 'TBD', super.key});

  /// Optional fixed width.
  final double? width;

  /// Optional fixed height.
  final double? height;

  /// Text shown inside the placeholder.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: AppRadii.card,
          border: Border.all(color: colorScheme.outline),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

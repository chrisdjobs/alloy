import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Outlined chip that picks one option out of a short list.
///
/// The selected chip fills with the accent; an optional [icon] is drawn in the
/// accent on the other chips, as in the visual references.
class AppChoiceChip extends StatelessWidget {
  /// Creates a chip that calls [onTap] when picked.
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    super.key,
  });

  /// Text of the option.
  final String label;

  /// Whether this option is the active one.
  final bool selected;

  /// Picked the option.
  final VoidCallback onTap;

  /// Optional glyph before the label.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(AppRadii.sm);

    return Material(
      color: selected ? accent : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: selected ? accent : AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppSizing.chipIcon,
                  color: selected ? AppColors.onAccent : accent,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.onAccent : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

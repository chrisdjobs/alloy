import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/tbd_placeholder.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder body for a destination whose content is not built yet.
///
/// It shows the TBD asset placeholder plus a caption instead of inventing
/// fake content.
class ComingSoon extends StatelessWidget {
  /// Creates the placeholder with [label] as its caption.
  const new({required this.label, super.key});

  /// Caption under the placeholder.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TbdPlaceholder(width: 132, height: 132),
            const SizedBox(height: AppSpacing.lg),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

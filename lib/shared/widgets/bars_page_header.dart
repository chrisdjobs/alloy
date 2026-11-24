import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Header shared by the top-level destinations and the settings sub-screens.
///
/// A large left-aligned title, an optional [leading] widget (usually a back
/// button) and trailing [actions], as in the visual references.
class BarsPageHeader extends StatelessWidget {
  /// Creates the header.
  const new({
    required this.title,
    this.actions = const [],
    this.leading,
    super.key,
  });

  /// Page title, rendered with the headline style.
  final String title;

  /// Trailing icon buttons.
  final List<Widget> actions;

  /// Optional widget before the title.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          ?leading,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headline,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

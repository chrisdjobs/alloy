import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Failure message with a single recovery action.
class RetryMessage extends StatelessWidget {
  /// Creates the message.
  const new({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  /// What went wrong.
  final String message;

  /// Label of the recovery action.
  final String actionLabel;

  /// Recovery action.
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onAction,
            icon: Icon(context.icons.refresh),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/tbd_placeholder.dart';
import 'package:material_ui/material_ui.dart';

/// Empty library state: an illustration slot, the reason and the folder action.
///
/// Shared by the screens that need tracks before they can show anything.
class NoTracksState extends StatelessWidget {
  /// Creates the state; [onChooseFolder] opens the folder picker.
  const new({required this.onChooseFolder, super.key});

  /// Opens the folder picker.
  final VoidCallback onChooseFolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const TbdPlaceholder(width: 132, height: 132),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noTracksFound,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onChooseFolder,
            icon: Icon(context.icons.folder),
            label: Text(l10n.chooseFolder),
          ),
        ],
      ),
    );
  }
}

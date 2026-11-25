import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/alloy_page_header.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Page of a settings sub-screen: back arrow, title and a scrollable body.
class SettingsSubScreen extends StatelessWidget {
  /// Creates the page with [children] under the header.
  const new({required this.title, required this.children, super.key});

  /// Title shown next to the back arrow.
  final String title;

  /// Content under the header.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AlloyPageHeader(
            title: title,
            leading: IconButton(
              onPressed: () => context.pop(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Icon(context.icons.back),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Row that opens a settings sub-screen.
class SettingsRow extends StatelessWidget {
  /// Creates a row that calls [onTap] when activated.
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  /// Glyph on the left.
  final IconData icon;

  /// Row title.
  final String title;

  /// Secondary line under the title.
  final String subtitle;

  /// Opens the sub-screen.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppSizing.settingsRowIcon,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              context.icons.forward,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uppercase section title of a settings screen.
class SettingsSection extends StatelessWidget {
  /// Creates the section title.
  const new({required this.title, this.accent = false, super.key});

  /// Title, rendered in uppercase.
  final String title;

  /// Whether the title takes the accent color, as in the storage reference.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Text(
        title.toUpperCase(),
        style: accent
            ? AppTextStyles.sectionHeader.copyWith(
                color: Theme.of(context).colorScheme.primary,
              )
            : AppTextStyles.sectionHeader,
      ),
    );
  }
}

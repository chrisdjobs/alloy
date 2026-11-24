import 'package:bars/shared/design/gradients.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/bars_page_header.dart';
import 'package:material_ui/material_ui.dart';

/// Home header: the page title over an accent glow, then the quick actions.
///
/// The glow is generated from the accent color and scrolls away with the
/// content, like the reference.
class HomeHeader extends StatelessWidget {
  /// Creates the header with [quickActions] under the title.
  const new({required this.title, this.quickActions = const [], super.key});

  /// Page title.
  final String title;

  /// Shortcut cards; the row is omitted when empty.
  final List<Widget> quickActions;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.accentGlow(accent),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(bottom: false, child: BarsPageHeader(title: title)),
            if (quickActions.isEmpty)
              const SizedBox(height: AppSpacing.lg)
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < quickActions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(child: quickActions[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ],
    );
  }
}

/// Dark shortcut card with an accent icon and a label.
class QuickAccessCard extends StatelessWidget {
  /// Creates the card.
  const new({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  /// Label under the icon.
  final String label;

  /// Accent glyph.
  final IconData icon;

  /// Action of the card.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: AppSizing.quickAccessHeight,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 24, color: accent),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

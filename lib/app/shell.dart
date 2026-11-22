import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/gradients.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Width at which the shell switches from bottom navigation to a sidebar.
const double shellBreakpoint = 600;

/// Persistent shell around the Library and Settings branches.
class AdaptiveShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const new({required this.navigationShell, super.key});

  /// Branch navigator managed by go_router.
  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= shellBreakpoint;

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  right: false,
                  child: NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _select,
                    destinations: [
                      for (var i = 0; i < _destinations.length; i++)
                        NavigationRailDestination(
                          icon: _NavPill(
                            destination: _destinations[i],
                            selected: false,
                            width: 180,
                          ),
                          selectedIcon: _NavPill(
                            destination: _destinations[i],
                            selected: true,
                            width: 180,
                          ),
                          label: Text(_destinations[i].label.toUpperCase()),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _content()),
              ],
            ),
          );
        }

        return Scaffold(
          body: _content(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            destinations: [
              for (var i = 0; i < _destinations.length; i++)
                Center(
                  child: _NavPill(
                    destination: _destinations[i],
                    selected: i == navigationShell.currentIndex,
                    onTap: () => _select(i),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _content() {
    return Column(
      children: [
        Expanded(child: navigationShell),
        // The mini-player is inserted here in Phase 3.
        const SizedBox.shrink(key: Key('mini-player-slot')),
      ],
    );
  }
}

const _destinations = [
  _Destination(
    label: 'Library',
    icon: AppIcons.library,
    selectedIcon: AppIcons.libraryActive,
  ),
  _Destination(
    label: 'Settings',
    icon: AppIcons.settings,
    selectedIcon: AppIcons.settingsActive,
  ),
];

final class _Destination {
  const new({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _NavPill extends StatelessWidget {
  const new({
    required this.destination,
    required this.selected,
    this.onTap,
    this.width,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final foreground = selected ? AppColors.onAccent : AppColors.textSecondary;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: selected ? AppGradients.accent(accent) : null,
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            destination.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(color: foreground),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(onTap: onTap, borderRadius: AppRadii.pill, child: content),
    );
  }
}

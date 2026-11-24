import 'dart:async';

import 'package:bars/features/player/presentation/mini_player.dart';
import 'package:bars/features/settings/domain/app_settings.dart';
import 'package:bars/features/settings/presentation/settings_notifier.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/gradients.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:bars/shared/widgets/tbd_placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Width at which the shell switches from bottom navigation to a sidebar.
const double shellBreakpoint = 600;

/// Persistent shell around the top-level destinations.
class AdaptiveShell extends ConsumerWidget {
  /// Creates the shell around [navigationShell].
  const new({required this.navigationShell, super.key});

  /// Branch navigator managed by go_router.
  final StatefulNavigationShell navigationShell;

  void _select(AppTab tab) {
    // Branch index and tab index share the `AppTab` order (see the router).
    final index = AppTab.values.indexOf(tab);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(
      settingsProvider.select((settings) => settings.navOrder),
    );
    final current = AppTab.values[navigationShell.currentIndex];

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
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: TbdPlaceholder(width: 48, height: 48),
                    ),
                    selectedIndex: AppTab.values.indexOf(current),
                    onDestinationSelected: (index) =>
                        _select(AppTab.values[index]),
                    destinations: [
                      for (final tab in order)
                        NavigationRailDestination(
                          icon: _NavPill(tab: tab, selected: false, width: 180),
                          selectedIcon: _NavPill(
                            tab: tab,
                            selected: true,
                            width: 180,
                          ),
                          label: Text(_labelOf(tab, context).toUpperCase()),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _content(context)),
              ],
            ),
          );
        }

        return Scaffold(
          body: _content(context),
          bottomNavigationBar: _BarsBottomBar(
            tabs: order,
            current: current,
            onSelected: _select,
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Expanded(child: navigationShell),
        MiniPlayer(onOpen: () => unawaited(context.push<void>('/now-playing'))),
      ],
    );
  }
}

String _labelOf(AppTab tab, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return switch (tab) {
    AppTab.home => l10n.homeTitle,
    AppTab.discover => l10n.discoverTitle,
    AppTab.library => l10n.libraryTitle,
    AppTab.me => l10n.meTitle,
  };
}

IconData _iconOf(AppTab tab, AppIconSet icons) {
  return switch (tab) {
    AppTab.home => icons.home,
    AppTab.discover => icons.discover,
    AppTab.library => icons.library,
    AppTab.me => icons.me,
  };
}

/// Compact bottom bar: icon-only tabs with a gradient pill on the active one.
class _BarsBottomBar extends StatelessWidget {
  const new({
    required this.tabs,
    required this.current,
    required this.onSelected,
  });

  final List<AppTab> tabs;
  final AppTab current;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final icons = context.icons;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppSizing.navBarHeight,
        child: Row(
          children: [
            for (final tab in tabs)
              Expanded(
                child: _BottomTab(
                  label: _labelOf(tab, context),
                  icon: _iconOf(tab, icons),
                  selected: tab == current,
                  onTap: () => onSelected(tab),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppDurations.navPill,
              curve: Curves.easeOut,
              width: AppSizing.navPillWidth,
              height: AppSizing.navPillHeight,
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.accent(accent) : null,
                borderRadius: AppRadii.navPill,
              ),
              child: Icon(
                icon,
                size: AppSizing.navIcon,
                color: selected ? AppColors.onAccent : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // The line is always reserved so the icons do not move when the
            // selection changes; only the active tab draws its label.
            AnimatedOpacity(
              duration: AppDurations.navPill,
              opacity: selected ? 1 : 0,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const new({required this.tab, required this.selected, this.width});

  final AppTab tab;
  final bool selected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final foreground = selected ? AppColors.onAccent : AppColors.textSecondary;

    return AnimatedContainer(
      duration: AppDurations.navPill,
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
          Icon(_iconOf(tab, context.icons), size: 18, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _labelOf(tab, context).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

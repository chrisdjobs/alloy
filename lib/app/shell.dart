import 'dart:async';

import 'package:alloy/features/player/presentation/mini_player.dart';
import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/gradient_presets_provider.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/preset_glow.dart';
import 'package:alloy/shared/widgets/tbd_placeholder.dart';
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
    final glow = ref.watch(activeGradientPresetProvider).glow;

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
                          icon: _NavPill(
                            tab: tab,
                            selected: false,
                            width: 180,
                            glow: glow,
                          ),
                          selectedIcon: _NavPill(
                            tab: tab,
                            selected: true,
                            width: 180,
                            glow: glow,
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
          bottomNavigationBar: _AlloyBottomBar(
            tabs: order,
            current: current,
            onSelected: _select,
            glow: glow,
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

/// Compact bottom bar: icon-only tabs with a gradient pill that slides
/// between the slots.
class _AlloyBottomBar extends StatelessWidget {
  const new({
    required this.tabs,
    required this.current,
    required this.onSelected,
    required this.glow,
  });

  final List<AppTab> tabs;
  final AppTab current;
  final ValueChanged<AppTab> onSelected;
  final List<RadialGradient> glow;

  @override
  Widget build(BuildContext context) {
    final icons = context.icons;
    final selectedIndex = tabs.indexOf(current);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppSizing.navBarHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / tabs.length;
            // Same height the label line takes, so the pill lines up with the
            // icons no matter how the slot is laid out.
            final labelHeight =
                MediaQuery.textScalerOf(context)
                    .scale(AppTextStyles.label.fontSize!) *
                AppTextStyles.label.height!;
            final top =
                (AppSizing.navBarHeight -
                    AppSizing.navPillHeight -
                    AppSpacing.xs -
                    labelHeight) /
                2;

            return Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: AppDurations.navSlide,
                  curve: Curves.easeOutCubic,
                  left:
                      slot * selectedIndex +
                      (slot - AppSizing.navPillWidth) / 2,
                  top: top,
                  width: AppSizing.navPillWidth,
                  height: AppSizing.navPillHeight,
                  child: ClipRRect(
                    borderRadius: AppRadii.navPill,
                    child: PresetGlow(layers: glow, fadeOut: false),
                  ),
                ),
                Row(
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomTab extends StatefulWidget {
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
  State<_BottomTab> createState() => _BottomTabState();
}

class _BottomTabState extends State<_BottomTab> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        // The only tap feedback is the icon shrinking; no splash or highlight
        // may be drawn over the tab.
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppSizing.navPillWidth,
              height: AppSizing.navPillHeight,
              child: Center(
                child: AnimatedScale(
                  scale: _pressed ? 0.82 : 1,
                  duration: _pressed
                      ? AppDurations.navPress
                      : AppDurations.navPill,
                  curve: Curves.easeOut,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: widget.selected ? 1 : 0),
                    duration: AppDurations.navSlide,
                    curve: Curves.easeOutCubic,
                    builder: (context, tint, _) => Icon(
                      widget.icon,
                      size: AppSizing.navIcon,
                      color: Color.lerp(
                        AppColors.textSecondary,
                        AppColors.textPrimary,
                        tint,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // The line is always reserved so the icons do not move when the
            // selection changes; only the active tab draws its label.
            AnimatedOpacity(
              duration: AppDurations.navPill,
              opacity: widget.selected ? 1 : 0,
              child: Text(
                widget.label.toUpperCase(),
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
  const new({
    required this.tab,
    required this.selected,
    required this.glow,
    this.width,
  });

  final AppTab tab;
  final bool selected;
  final List<RadialGradient> glow;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return AnimatedContainer(
      duration: AppDurations.navPill,
      curve: Curves.easeOut,
      width: width,
      clipBehavior: selected ? Clip.antiAlias : Clip.none,
      decoration: const BoxDecoration(borderRadius: AppRadii.pill),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (selected)
            Positioned.fill(child: PresetGlow(layers: glow, fadeOut: false)),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
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
          ),
        ],
      ),
    );
  }
}

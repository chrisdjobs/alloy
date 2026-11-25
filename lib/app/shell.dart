import 'package:alloy/features/player/presentation/mini_player.dart';
import 'package:alloy/features/player/presentation/now_playing_screen.dart';
import 'package:alloy/features/player/presentation/player_notifier.dart';
import 'package:alloy/features/player/presentation/player_panel_provider.dart';
import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/gradient_presets_provider.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/preset_glow.dart';
import 'package:alloy/shared/widgets/tbd_placeholder.dart';
import 'package:flutter/physics.dart' show SpringDescription, SpringSimulation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Width at which the shell switches from bottom navigation to a sidebar.
const double shellBreakpoint = 600;

/// Fraction of the expansion over which the mini-player fades out.
const double _miniPlayerFadeEnd = 0.25;

/// Vertical speed (px/s) that settles the panel in the fling direction.
const double _panelFlingVelocity = 500;

/// Spring used to settle the panel after a drag.
const SpringDescription _panelSpring = SpringDescription(
  mass: 1,
  stiffness: 260,
  damping: 32,
);

/// Persistent shell around the top-level destinations.
class AdaptiveShell extends ConsumerStatefulWidget {
  /// Creates the shell around [navigationShell].
  const new({required this.navigationShell, super.key});

  /// Branch navigator managed by go_router.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _panelController;
  late final PlayerPanelController _panelActions;
  final GlobalKey _barKey = GlobalKey();

  var _barHeight = 0.0;
  var _panelTravel = 0.0;
  var _dragStartY = 0.0;
  var _dragStartT = 0.0;
  var _isDragging = false;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: AppDurations.playerOpen,
      value: 0,
    );
    _panelActions = ref.read(playerPanelProvider)
      ..controller = _panelController;
  }

  @override
  void dispose() {
    _panelActions.controller = null;
    _panelController.dispose();
    super.dispose();
  }

  void _select(AppTab tab) {
    // Branch index and tab index share the `AppTab` order (see the router).
    final index = AppTab.values.indexOf(tab);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onPanelDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _dragStartT = _panelController.value;
    _isDragging = true;
    _panelController.stop();
  }

  void _onPanelDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _panelTravel <= 0) return;
    final dy = details.globalPosition.dy - _dragStartY;
    // Dragging up (negative dy) expands the panel; the top follows the finger.
    _panelController.value = (_dragStartT - dy / _panelTravel).clamp(0.0, 1.0);
  }

  void _onPanelDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    _settlePanel(details.primaryVelocity ?? 0);
  }

  void _onPanelDragCancel() {
    if (!_isDragging) return;
    _isDragging = false;
    _settlePanel(0);
  }

  /// Settles the panel to 0 or 1 with a spring, honouring the fling velocity.
  void _settlePanel(double velocity) {
    final target = velocity < -_panelFlingVelocity
        ? 1.0
        : velocity > _panelFlingVelocity
        ? 0.0
        : _panelController.value >= 0.5
        ? 1.0
        : 0.0;
    _panelController.animateWith(
      SpringSimulation(
        _panelSpring,
        _panelController.value,
        target,
        _panelTravel <= 0 ? 0 : -velocity / _panelTravel,
      ),
    );
  }

  void _syncBarHeight() {
    if (!mounted) return;
    final height = _barKey.currentContext?.size?.height ?? 0;
    if (height > 0 && (height - _barHeight).abs() > 0.5) {
      setState(() => _barHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(
      settingsProvider.select((settings) => settings.navOrder),
    );
    final current = AppTab.values[widget.navigationShell.currentIndex];
    final glow = ref.watch(activeGradientPresetProvider).glow;
    // Rebuild when the mini-player appears or disappears so the reserved space
    // at the bottom is measured again.
    ref.watch(playerProvider.select((state) => state.value?.track != null));
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final navBarHeight = AppSizing.navBarHeight + safeBottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= shellBreakpoint;
        _panelTravel = (constraints.maxHeight - _barHeight).clamp(
          0.0,
          double.infinity,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncBarHeight());

        final base = Column(
          children: [
            Expanded(child: widget.navigationShell),
            SizedBox(height: _barHeight),
          ],
        );

        final shell = AnimatedBuilder(
          animation: _panelController,
          builder: (context, child) {
            final t = _panelController.value;
            return PopScope(
              // Back closes the panel before it leaves the shell.
              canPop: t < 0.001,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _panelActions.collapse();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  child!,
                  if (t > 0)
                    Positioned(
                      top: _panelTravel * (1 - t),
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: NowPlayingPanel(
                        t: t,
                        barHeight: _barHeight,
                        onDragStart: _onPanelDragStart,
                        onDragUpdate: _onPanelDragUpdate,
                        onDragEnd: _onPanelDragEnd,
                        onDragCancel: _onPanelDragCancel,
                      ),
                    ),
                  _barLayer(
                    t: t,
                    wide: wide,
                    navBarHeight: wide ? 0 : navBarHeight,
                    order: order,
                    current: current,
                    glow: glow,
                  ),
                ],
              ),
            );
          },
          child: base,
        );

        if (!wide) return Scaffold(body: shell);

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
              Expanded(child: shell),
            ],
          ),
        );
      },
    );
  }

  /// Bottom bar layer: mini-player plus navigation bar on compact layouts.
  ///
  /// It sits above the panel so the mini-player fade and the navigation bar
  /// slide stay visible while the panel expands behind them.
  Widget _barLayer({
    required double t,
    required bool wide,
    required double navBarHeight,
    required List<AppTab> order,
    required AppTab current,
    required List<RadialGradient> glow,
  }) {
    final miniOpacity = (1 - t / _miniPlayerFadeEnd).clamp(0.0, 1.0);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: KeyedSubtree(
        key: _barKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              // Once the panel moves, the mini-player must not eat its taps.
              ignoring: t > 0.001,
              child: Opacity(
                opacity: miniOpacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: _onPanelDragStart,
                  onVerticalDragUpdate: _onPanelDragUpdate,
                  onVerticalDragEnd: _onPanelDragEnd,
                  onVerticalDragCancel: _onPanelDragCancel,
                  child: MiniPlayer(onOpen: _panelActions.expand),
                ),
              ),
            ),
            if (!wide)
              Transform.translate(
                offset: Offset(0, t * navBarHeight),
                child: _AlloyBottomBar(
                  tabs: order,
                  current: current,
                  onSelected: _select,
                  glow: glow,
                ),
              ),
          ],
        ),
      ),
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
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
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
                    duration: AppDurations.navPill,
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

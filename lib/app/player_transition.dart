import 'package:alloy/features/player/presentation/drag_dismiss_route.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Page for the now-playing screen, which slides up over the shell.
Page<void> playerPage({required Widget child, LocalKey? key}) {
  return _PlayerPage(key: key, child: child);
}

class _PlayerPage extends Page<void> {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return _PlayerRoute(settings: this, child: child);
  }
}

/// Slides its page up from the bottom and lets the screen drag it back down.
class _PlayerRoute extends PageRoute<void> implements DragDismissRoute {
  new({required this.child, super.settings});

  final Widget child;

  var _dragging = false;

  @override
  Duration get transitionDuration => AppDurations.playerOpen;

  @override
  Duration get reverseTransitionDuration => AppDurations.playerClose;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  AnimationController createAnimationController() {
    return super.createAnimationController()..addStatusListener((status) {
      if (status == AnimationStatus.completed) _dragging = false;
    });
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final value = animation.value;
    // A drag, a snap back and a drag-dismiss follow the finger one to one;
    // only a plain push or pop eases.
    final reveal = _dragging
        ? value
        : switch (animation.status) {
            AnimationStatus.reverse => Curves.easeInCubic.transform(value),
            _ => Curves.easeOutCubic.transform(value),
          };
    return FractionalTranslation(
      translation: Offset(0, 1 - reveal),
      child: child,
    );
  }

  @override
  bool beginDrag() {
    final controller = this.controller!;
    if (controller.status != AnimationStatus.completed) return false;
    controller.stop();
    _dragging = true;
    return true;
  }

  @override
  void updateDrag(double fraction) {
    if (!_dragging) return;
    final controller = this.controller!;
    controller.value = (controller.value - fraction).clamp(0.0, 1.0);
  }

  @override
  void dismiss() {
    navigator?.pop();
  }

  @override
  void settle() {
    if (!_dragging) return;
    controller!.animateTo(
      1,
      duration: AppDurations.playerOpen,
      curve: Curves.easeOutCubic,
    );
  }
}

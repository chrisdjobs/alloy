import 'package:alloy/shared/design/tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Branch container for the shell that cross-fades when the active branch
/// changes.
///
/// Every branch stays mounted, so scroll offsets and form state survive tab
/// switches. After the fade, inactive branches go offstage, stop their
/// animations and leave the semantics tree.
Widget fadeBranchContainer(
  BuildContext context,
  StatefulNavigationShell navigationShell,
  List<Widget> children,
) {
  return _BranchFade(
    currentIndex: navigationShell.currentIndex,
    children: children,
  );
}

class _BranchFade extends StatefulWidget {
  const new({required this.currentIndex, required this.children});

  final int currentIndex;
  final List<Widget> children;

  @override
  State<_BranchFade> createState() => _BranchFadeState();
}

class _BranchFadeState extends State<_BranchFade> {
  late int _active = widget.currentIndex;
  int? _leaving;

  @override
  void didUpdateWidget(_BranchFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _active) {
      _leaving = _active;
      _active = widget.currentIndex;
    }
  }

  void _clearLeaving(int index) {
    if (index != _leaving) return;
    setState(() => _leaving = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < widget.children.length; index++)
          _branch(index),
      ],
    );
  }

  Widget _branch(int index) {
    final active = index == _active;
    final leaving = index == _leaving;

    return Offstage(
      offstage: !active && !leaving,
      child: IgnorePointer(
        ignoring: !active,
        child: ExcludeSemantics(
          excluding: !active,
          child: AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: AppDurations.branchFade,
            curve: Curves.easeInOut,
            onEnd: () => _clearLeaving(index),
            child: TickerMode(enabled: active, child: widget.children[index]),
          ),
        ),
      ),
    );
  }
}

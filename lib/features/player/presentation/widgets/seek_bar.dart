import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Slim accent seek bar.
///
/// A drag previews the new position locally and seeks once the finger is
/// lifted, so the 200 ms position stream never fights the gesture.
class SeekBar extends StatefulWidget {
  /// Creates a bar showing [position] inside [duration].
  const new({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
  });

  /// Current playback position.
  final Duration position;

  /// Length of the current track; null disables seeking.
  final Duration? duration;

  /// Called once when the user picks a position.
  final ValueChanged<Duration> onSeek;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  /// Fraction shown while dragging, before the seek is committed.
  double? _preview;

  double _fraction(Duration? duration) {
    final total = duration?.inMilliseconds ?? 0;
    if (total <= 0) return 0;
    return (widget.position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  void _previewAt(double dx, double width) {
    if (widget.duration == null || width <= 0) return;
    setState(() => _preview = (dx / width).clamp(0.0, 1.0));
  }

  void _commit(double width) {
    final preview = _preview;
    setState(() => _preview = null);
    final duration = widget.duration;
    if (duration == null || preview == null) return;
    widget.onSeek(duration * preview);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final fraction = _preview ?? _fraction(widget.duration);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final duration = widget.duration;

        return Semantics(
          slider: true,
          value: '${(fraction * 100).round()}%',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: duration == null
                ? null
                : (details) => widget.onSeek(
                    duration *
                        (details.localPosition.dx / width).clamp(0.0, 1.0),
                  ),
            onHorizontalDragStart: (details) =>
                _previewAt(details.localPosition.dx, width),
            onHorizontalDragUpdate: (details) =>
                _previewAt(details.localPosition.dx, width),
            onHorizontalDragEnd: (_) => _commit(width),
            onHorizontalDragCancel: () => setState(() => _preview = null),
            child: SizedBox(
              height: AppSizing.seekBarTouchHeight,
              child: Center(
                child: ClipRRect(
                  borderRadius: AppRadii.pill,
                  child: SizedBox(
                    height: AppSizing.seekBarHeight,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: ColoredBox(color: AppColors.outline),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fraction,
                          heightFactor: 1,
                          child: ColoredBox(color: accent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

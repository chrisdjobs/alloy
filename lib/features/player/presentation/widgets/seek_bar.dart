import 'dart:math' as math;

import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Waveform seek bar.
///
/// The audio is not analysed yet, so the bars come from [seed]: the track keeps
/// a stable shape while the screen keeps the waveform look of the references.
/// A drag previews the new position locally and seeks once the finger is
/// lifted, so the 200 ms position stream never fights the gesture.
class SeekBar extends StatefulWidget {
  /// Creates a bar showing [position] inside [duration].
  const new({
    required this.position,
    required this.duration,
    required this.onSeek,
    this.seed = 0,
    super.key,
  });

  /// Current playback position.
  final Duration position;

  /// Length of the current track; null disables seeking.
  final Duration? duration;

  /// Called once when the user picks a position.
  final ValueChanged<Duration> onSeek;

  /// Seed of the generated waveform; pass something stable per track.
  final int seed;

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
            child: CustomPaint(
              size: Size(width, AppSizing.waveformHeight),
              painter: _WaveformPainter(
                fraction: fraction,
                seed: widget.seed,
                playedColor: accent,
                remainingColor: AppColors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  new({
    required this.fraction,
    required this.seed,
    required this.playedColor,
    required this.remainingColor,
  });

  final double fraction;
  final int seed;
  final Color playedColor;
  final Color remainingColor;

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = AppSizing.waveformBarWidth;
    const step = barWidth + AppSizing.waveformBarGap;
    final count = (size.width / step).floor();
    if (count <= 0) return;

    // Center the bars so a partial bar never leaves a ragged right gutter.
    final firstX = (size.width - (count * step - AppSizing.waveformBarGap)) / 2;
    final centerY = size.height / 2;
    final playedUntil = size.width * fraction;
    final random = math.Random(seed);
    final paint = Paint()
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final x = firstX + i * step + barWidth / 2;
      final envelope = 0.15 + random.nextDouble() * 0.85;
      final halfHeight = size.height * envelope / 2;
      paint.color = x <= playedUntil ? playedColor : remainingColor;
      canvas.drawLine(
        Offset(x, centerY - halfHeight),
        Offset(x, centerY + halfHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.seed != seed ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.remainingColor != remainingColor;
  }
}

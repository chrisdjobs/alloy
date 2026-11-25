import 'package:alloy/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Gradients generated in code from the current accent color.
abstract final class AppGradients {
  /// Diagonal accent gradient with lighter and darker stops derived from
  /// [accent].
  static LinearGradient accent(Color accent) {
    final hsl = HSLColor.fromColor(accent);

    Color shift(double delta) =>
        hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [shift(0.14), accent, shift(-0.14)],
      stops: const [0, 0.5, 1],
    );
  }

  /// Vertical fade from a cover-derived [color] into the [base] background.
  ///
  /// [color] is expected to be already darkened enough for readable text
  /// (`AppColors.minCoverTextContrast`); this helper only shapes the gradient.
  static LinearGradient coverFade(
    Color color, {
    Color base = AppColors.background,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color, base],
    );
  }
}

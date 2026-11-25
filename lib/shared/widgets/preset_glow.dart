import 'package:material_ui/material_ui.dart';

/// Paints a preset glow as a full-width, multi-color wash that fades out
/// vertically.
///
/// The preset's glow is one [RadialGradient] per icon layer, so the wash keeps
/// the icon's colors left to right. Each shader is stretched horizontally:
/// [RadialGradient] resolves `radius` against the box's shortest side, so its
/// horizontal radius becomes `radius * width` and its vertical radius stays
/// `radius * height`. A [ShaderMask] then fades the whole stack from top to
/// bottom, so the glow needs no page color and is never clipped.
class PresetGlow extends StatelessWidget {
  /// Creates the glow from the preset's glow [layers].
  const new({required this.layers, super.key});

  /// One radial gradient per glow layer, usually the active preset's `glow`.
  final List<RadialGradient> layers;

  /// Vertical fade of the glow stack, top to bottom.
  ///
  /// Mirrors `GLOW_FADE` in `tools/gradients/gradient_preset.py`: white at
  /// alpha 1.0 / 0.65 / 0.0 at stops 0 / 0.4 / 1. Change both together.
  static const LinearGradient fade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xA6FFFFFF), Color(0x00FFFFFF)],
    stops: [0, 0.4, 1],
  );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: fade.createShader,
          child: Stack(
            fit: StackFit.expand,
            children: [for (final layer in layers) _Layer(layer)],
          ),
        ),
      ),
    );
  }
}

/// One glow layer stretched to the box width.
class _Layer extends StatelessWidget {
  const new(this.layer);

  final RadialGradient layer;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: layer.center,
          radius: layer.radius,
          colors: layer.colors,
          stops: layer.stops,
          tileMode: layer.tileMode,
          focal: layer.focal,
          focalRadius: layer.focalRadius,
          transform: _StretchAroundCenter(
            center: layer.center,
            inner: layer.transform,
          ),
        ),
      ),
    );
  }
}

/// Scales the gradient shader horizontally around its center.
class _StretchAroundCenter extends GradientTransform {
  const new({required this.center, this.inner});

  final AlignmentGeometry center;
  final GradientTransform? inner;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    if (bounds.isEmpty) return null;

    final pivot = center.resolve(textDirection).withinRect(bounds);
    final stretch = Matrix4.identity()
      ..translateByDouble(pivot.dx, pivot.dy, 0, 1)
      ..scaleByDouble(bounds.width / bounds.height, 1, 1, 1)
      ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1);
    final innerMatrix = inner?.transform(bounds, textDirection: textDirection);
    return innerMatrix == null ? stretch : stretch.multiplied(innerMatrix);
  }
}

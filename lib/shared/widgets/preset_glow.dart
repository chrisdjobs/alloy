import 'package:material_ui/material_ui.dart';

/// Paints a preset glow as a full-width, multi-color wash.
///
/// The preset's glow is one [RadialGradient] per icon layer, so the wash keeps
/// the icon's colors left to right. Each shader is stretched horizontally:
/// [RadialGradient] resolves `radius` against the box's shortest side, so its
/// horizontal radius becomes `radius * width` and its vertical radius stays
/// `radius * height`.
///
/// With [fadeOut] the whole stack is masked by [fadeMask], which blends the
/// bottom into the page background (Home). Without it the box is opaque: a
/// left-to-right underlay of the layers' own colors fills the gaps where the
/// radials fall to zero, so the widget shows gradient colors only, never the
/// page background (the Me identity card and the nav pill).
class PresetGlow extends StatelessWidget {
  /// Creates the glow from the preset's glow [layers].
  const new({required this.layers, this.fadeOut = true, super.key});

  /// One radial gradient per glow layer, usually the active preset's `glow`.
  final List<RadialGradient> layers;

  /// Whether the wash fades out towards the bottom.
  ///
  /// Only the page glow behind Home fades: it must blend into the background.
  /// The Me card and the pill keep their color to the edge and stay opaque.
  final bool fadeOut;

  /// Vertical fade of the glow stack, top to bottom.
  ///
  /// Mirrors `GLOW_FADE` in `tools/gradients/gradient_preset.py`: white at
  /// alpha 1.0 / 0.65 / 0.0 at stops 0 / 0.4 / 1. Change both together.
  static const LinearGradient fadeMask = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xA6FFFFFF), Color(0x00FFFFFF)],
    stops: [0, 0.4, 1],
  );

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      fit: StackFit.expand,
      children: [
        if (!fadeOut) _Underlay(layers),
        for (final layer in layers) _Layer(layer),
      ],
    );

    return IgnorePointer(
      child: RepaintBoundary(
        child: fadeOut
            ? ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: fadeMask.createShader,
                child: stack,
              )
            : stack,
      ),
    );
  }
}

/// Opaque base of a non-faded wash: the layers' colors, left to right, pushed
/// towards black so the card and the pill sit at the page glow's darkness
/// instead of a full-strength fill.
class _Underlay extends StatelessWidget {
  const new(this.layers);

  final List<RadialGradient> layers;

  /// How far the underlay colors move towards black.
  ///
  /// The page glow shows the same colors over the near-black base at reduced
  /// alphas; a quarter of each color here keeps that dark, elegant level.
  static const double _dim = 0.75;

  @override
  Widget build(BuildContext context) {
    final colors = [
      for (final layer in layers)
        Color.lerp(layer.colors.first, const Color(0xFF000000), _dim)!,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.length > 1 ? colors : [colors.first, colors.first],
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

import 'package:alloy/shared/design/gradient_presets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preset selected in `assets/icon/presets.json` when the app was built.
///
/// A provider keeps widgets off the generated static and lets tests or a
/// future theme switcher override the active preset without touching them.
final activeGradientPresetProvider = Provider<GradientPreset>(
  (_) => AppGradientPresets.active,
);

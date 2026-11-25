import 'package:alloy/shared/design/tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Handle the shell hands to the app so widgets can expand or collapse the
/// now-playing panel without reaching into the shell state.
class PlayerPanelController {
  /// The controller owned by the shell, or null while no shell is mounted.
  AnimationController? controller;

  /// Expands the panel to full screen.
  void expand() {
    controller?.animateTo(
      1,
      duration: AppDurations.playerOpen,
      curve: Curves.easeOutCubic,
    );
  }

  /// Collapses the panel back to the mini-player.
  void collapse() {
    controller?.animateTo(
      0,
      duration: AppDurations.playerClose,
      curve: Curves.easeInCubic,
    );
  }
}

/// Exposes the shell's panel controller to the rest of the app.
final playerPanelProvider = Provider<PlayerPanelController>((_) {
  return PlayerPanelController();
});

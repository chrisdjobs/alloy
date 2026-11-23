import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// Secondary actions of the now-playing screen.
///
/// Only actions that exist on `PlaybackEngine` are listed. Favorites, lyrics,
/// sharing and the sleep timer are not built yet, so they are not rendered.
class NowPlayingOverflowMenu extends StatelessWidget {
  /// Creates the menu; the only entry calls [onStop].
  const new({required this.onStop, super.key});

  /// Stops playback.
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    return PopupMenuButton<_NowPlayingAction>(
      icon: const Icon(AppIcons.more),
      tooltip: l10n.moreOptions,
      onSelected: (action) {
        switch (action) {
          case _NowPlayingAction.stop:
            onStop();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _NowPlayingAction.stop,
          child: Row(
            children: [
              Icon(AppIcons.stop, size: 18, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.stopPlayback),
            ],
          ),
        ),
      ],
    );
  }
}

enum _NowPlayingAction { stop }

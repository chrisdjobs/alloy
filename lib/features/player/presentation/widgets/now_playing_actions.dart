import 'package:alloy/features/player/presentation/widgets/overflow_menu.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom action row of the now-playing screen.
///
/// Actions that are not built yet are drawn disabled, so the row keeps the
/// same shape as the design while missing features stay unreachable.
class NowPlayingActions extends StatelessWidget {
  /// Creates the row.
  const new({
    required this.onStop,
    this.onShare,
    this.onLyrics,
    this.onQueue,
    super.key,
  });

  /// Shares the current track; disabled while sharing is not built.
  final VoidCallback? onShare;

  /// Shows the lyrics of the current track; disabled until the lyrics slice.
  final VoidCallback? onLyrics;

  /// Opens the playback queue; disabled until the queue sheet exists.
  final VoidCallback? onQueue;

  /// Stops playback from the overflow menu.
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        _Action(
          icon: context.icons.share,
          tooltip: l10n.share,
          onPressed: onShare,
        ),
        _Action(
          icon: context.icons.lyrics,
          tooltip: l10n.lyrics,
          onPressed: onLyrics,
        ),
        _Action(
          icon: context.icons.queue,
          tooltip: l10n.queue,
          onPressed: onQueue,
        ),
        Expanded(
          child: Center(
            child: IconTheme.merge(
              data: const IconThemeData(color: AppColors.textSecondary),
              child: NowPlayingOverflowMenu(onStop: onStop),
            ),
          ),
        ),
      ],
    );
  }
}

/// One slot of the row, sized so the four actions share the width evenly.
class _Action extends StatelessWidget {
  const new({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(icon),
          iconSize: AppSpacing.xl,
          color: AppColors.textSecondary,
          disabledColor: AppColors.textMuted,
        ),
      ),
    );
  }
}

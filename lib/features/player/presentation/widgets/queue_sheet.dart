import 'package:alloy/core/utils/duration_format.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/player/domain/playback_state.dart';
import 'package:alloy/features/player/presentation/player_notifier.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Height of the queue sheet as a fraction of the screen.
const double _sheetHeightFactor = 0.75;

/// Shows the playback queue over the now-playing screen.
Future<void> showQueueSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (context) => const FractionallySizedBox(
      heightFactor: _sheetHeightFactor,
      child: QueueSheet(),
    ),
  );
}

/// Tracks loaded in the player, with the current one highlighted.
class QueueSheet extends ConsumerWidget {
  /// Creates the sheet.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playback = ref.watch(playerProvider);

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: AppSizing.sheetHandleWidth,
              height: AppSizing.sheetHandleHeight,
              decoration: const BoxDecoration(
                color: AppColors.outline,
                borderRadius: AppRadii.pill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.sm,
            ),
            child: Text(l10n.queue, style: AppTextStyles.title),
          ),
          Expanded(
            child: switch (playback) {
              AsyncData(:final value) =>
                value.queue.isEmpty
                    ? const _EmptyQueue()
                    : _QueueList(state: value),
              AsyncError() => Center(
                child: Text(
                  l10n.error,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _QueueList extends StatelessWidget {
  const new({required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: state.queue.length,
      itemBuilder: (context, index) {
        final track = state.queue[index];
        final current = index == state.queueIndex;
        return _QueueRow(
          track: track,
          current: current,
          playing: current && state.playing,
        );
      },
    );
  }
}

class _QueueRow extends StatelessWidget {
  const new({
    required this.track,
    required this.current,
    required this.playing,
  });

  final Track track;
  final bool current;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final duration = track.duration;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          ArtworkImage(artworkRef: track.artworkRef),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.trackTitle.copyWith(
                    color: current ? accent : AppColors.textPrimary,
                  ),
                ),
                if (track.artist != null)
                  Text(
                    track.artist!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.trackArtist.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (current) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              playing ? context.icons.pause : context.icons.play,
              color: accent,
              size: AppSpacing.lg,
            ),
          ] else if (duration != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              formatTrackDuration(duration),
              style: AppTextStyles.trackArtist.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Text(
        l10n.queueEmpty,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

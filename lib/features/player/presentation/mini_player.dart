import 'package:bars/features/player/domain/playback_state.dart';
import 'package:bars/features/player/presentation/player_hero.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:bars/shared/widgets/cover_backdrop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Compact player pinned to the bottom of the shell.
///
/// Hidden while nothing is loaded, so the shell keeps its full height.
class MiniPlayer extends ConsumerWidget {
  /// Creates the mini-player.
  ///
  /// [leading] and [backdrop] are slots for the artwork pipeline: they default
  /// to the track's cover thumbnail and an accent-tinted placeholder.
  ///
  /// [onOpen] receives a tap anywhere outside the buttons; the shell opens the
  /// now-playing screen from it.
  const new({this.leading, this.backdrop, this.onOpen, super.key});

  /// Cover slot on the left of the bar.
  final Widget? leading;

  /// Background slot behind the whole bar.
  final Widget? backdrop;

  /// Called when the bar itself (not one of its buttons) is tapped.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playerProvider);

    return switch (playback) {
      AsyncValue<PlaybackState>(hasError: true) => _ErrorBar(
        onRetry: () => ref.invalidate(playerProvider),
      ),
      AsyncValue<PlaybackState>(:final value?) when value.track != null =>
        _PlayerBar(
          state: value,
          leading: leading,
          backdrop: backdrop,
          onOpen: onOpen,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PlayerBar extends ConsumerWidget {
  const new({
    required this.state,
    required this.leading,
    required this.backdrop,
    required this.onOpen,
  });

  final PlaybackState state;
  final Widget? leading;
  final Widget? backdrop;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(playerProvider.notifier);
    final track = state.track!;
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.cardLarge,
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  backdrop ??
                  CoverBackdrop(
                    artworkRef: track.artworkRef,
                    fallback: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha: 0.16),
                            AppColors.surfaceHigh,
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onOpen,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.sm,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          leading ??
                              Hero(
                                tag: nowPlayingCoverHeroTag,
                                child: ArtworkImage(
                                  artworkRef: track.artworkRef,
                                  size: AppSizing.coverMiniPlayer,
                                ),
                              ),
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
                                    color: AppColors.textPrimary,
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
                          IconButton(
                            onPressed: () async {
                              await notifier.togglePlayPause();
                            },
                            tooltip: state.playing ? l10n.pause : l10n.play,
                            icon: Icon(
                              state.playing ? AppIcons.pause : AppIcons.play,
                              color: accent,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await notifier.next();
                            },
                            tooltip: l10n.next,
                            icon: const Icon(
                              AppIcons.next,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        value: _progress(state),
                        backgroundColor: Colors.transparent,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _progress(PlaybackState state) {
    final duration = state.duration;
    if (duration == null || duration.inMilliseconds <= 0) return 0;
    return (state.position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }
}

class _ErrorBar extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: AppColors.surfaceHigh,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(AppIcons.error, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.error,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

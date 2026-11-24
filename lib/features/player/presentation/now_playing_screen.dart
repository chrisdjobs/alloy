import 'dart:async';

import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/domain/playback_state.dart';
import 'package:bars/features/player/presentation/player_hero.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/features/player/presentation/widgets/cover_gradient.dart';
import 'package:bars/features/player/presentation/widgets/overflow_menu.dart';
import 'package:bars/features/player/presentation/widgets/seek_bar.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Flutter also exports a RepeatMode; playback has the one that matters here.
import 'package:material_ui/material_ui.dart' hide RepeatMode;

/// Full-screen player.
///
/// Renders only controls that exist today; the rows keep room for favorites,
/// lyrics or sharing without re-laying out the screen.
class NowPlayingScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  var _dragDistance = 0.0;

  void _dismiss() {
    _dragDistance = 0;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider).value;
    final track = state?.track;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0) _dragDistance += details.delta.dy;
        },
        onVerticalDragEnd: (_) {
          if (_dragDistance >= AppSizing.nowPlayingDismissDistance) {
            _dismiss();
          } else {
            _dragDistance = 0;
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CoverGradient(artworkRef: track?.artworkRef),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  key: const ValueKey('now-playing-content'),
                  constraints: const BoxConstraints(
                    maxWidth: AppSizing.nowPlayingMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    child: track == null
                        ? _EmptyPlayer(onClose: _dismiss)
                        : _PlayerBody(state: state!, track: track),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerBody extends ConsumerWidget {
  const new({required this.state, required this.track});

  final PlaybackState state;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(playerProvider.notifier);
    final technical = _technicalLine(l10n, state, track);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(title: track.album ?? l10n.nowPlaying),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                LayoutBuilder(
                  builder: (context, constraints) => Hero(
                    tag: nowPlayingCoverHeroTag,
                    child: ArtworkImage(
                      artworkRef: track.artworkRef,
                      size: constraints.maxWidth,
                      borderRadius: AppRadii.artworkLarge,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.playerTitle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (track.artist != null)
                        Text(
                          track.artist!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SeekBar(
                  position: state.position,
                  duration: state.duration,
                  onSeek: (position) => unawaited(notifier.seek(position)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(_formatDuration(state.position), style: _timeStyle),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Text(
                          technical ?? '',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: _timeStyle.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    Text(_formatDuration(state.duration), style: _timeStyle),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _Controls(state: state),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // More secondary actions (favorite, lyrics, sharing) join this row.
            NowPlayingOverflowMenu(onStop: () => unawaited(notifier.stop())),
          ],
        ),
      ],
    );
  }

  static String? _technicalLine(
    AppLocalizations l10n,
    PlaybackState state,
    Track track,
  ) {
    final parts = <String>[
      if (track.sampleRateHz != null &&
          track.bitrateKbps != null &&
          track.format != null)
        l10n.audioQuality(
          (track.sampleRateHz! / 1000).toStringAsFixed(1),
          '${track.bitrateKbps}',
          track.format!,
        ),
      if (state.queueIndex != null && state.queueLength != null)
        l10n.queuePosition(state.queueIndex! + 1, state.queueLength!),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _Controls extends ConsumerWidget {
  const new({required this.state});

  final PlaybackState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(playerProvider.notifier);
    final accent = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => unawaited(notifier.setShuffle(!state.shuffle)),
          tooltip: l10n.shuffle,
          icon: const Icon(AppIcons.shuffle),
          color: state.shuffle ? accent : AppColors.textSecondary,
        ),
        IconButton(
          onPressed: () => unawaited(notifier.previous()),
          tooltip: l10n.previous,
          icon: const Icon(AppIcons.previous),
          iconSize: AppSpacing.xxl,
          color: AppColors.textPrimary,
        ),
        IconButton.filled(
          onPressed: () => unawaited(notifier.togglePlayPause()),
          tooltip: state.playing ? l10n.pause : l10n.play,
          icon: Icon(state.playing ? AppIcons.pause : AppIcons.play),
          iconSize: AppSpacing.xxl,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(AppSizing.nowPlayingPlayButton),
          ),
        ),
        IconButton(
          onPressed: () => unawaited(notifier.next()),
          tooltip: l10n.next,
          icon: const Icon(AppIcons.next),
          iconSize: AppSpacing.xxl,
          color: AppColors.textPrimary,
        ),
        IconButton(
          onPressed: () =>
              unawaited(notifier.setRepeatMode(_nextRepeat(state.repeatMode))),
          tooltip: _repeatTooltip(l10n, state.repeatMode),
          icon: Icon(
            state.repeatMode == RepeatMode.one
                ? AppIcons.repeatOne
                : AppIcons.repeat,
          ),
          color: state.repeatMode == RepeatMode.off
              ? AppColors.textSecondary
              : accent,
        ),
      ],
    );
  }

  static RepeatMode _nextRepeat(RepeatMode mode) => switch (mode) {
    RepeatMode.off => RepeatMode.all,
    RepeatMode.all => RepeatMode.one,
    RepeatMode.one => RepeatMode.off,
  };

  static String _repeatTooltip(AppLocalizations l10n, RepeatMode mode) {
    return switch (mode) {
      RepeatMode.off => l10n.repeatOff,
      RepeatMode.all => l10n.repeat,
      RepeatMode.one => l10n.repeatOne,
    };
  }
}

class _Header extends StatelessWidget {
  const new({required this.title, this.onClose});

  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: onClose ?? () => Navigator.of(context).maybePop(),
          tooltip: l10n.close,
          color: AppColors.textPrimary,
          icon: const Icon(AppIcons.collapse),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Mirrors the icon so the title stays centered.
        const SizedBox(width: AppSizing.iconButton),
      ],
    );
  }
}

class _EmptyPlayer extends StatelessWidget {
  const new({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          title: AppLocalizations.of(context).nowPlaying,
          onClose: onClose,
        ),
        const Spacer(),
      ],
    );
  }
}

final TextStyle _timeStyle = AppTextStyles.label.copyWith(
  color: AppColors.textSecondary,
  letterSpacing: 0.4,
);

String _formatDuration(Duration? duration) {
  if (duration == null) return '--:--';
  final seconds = duration.inSeconds;
  final minutes = seconds ~/ 60;
  final remainder = (seconds % 60).toString().padLeft(2, '0');
  final hours = minutes ~/ 60;
  if (hours == 0) return '$minutes:$remainder';
  return '$hours:${(minutes % 60).toString().padLeft(2, '0')}:$remainder';
}

import 'dart:async';

import 'package:alloy/core/artwork/artwork_providers.dart';
import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/artwork/artwork_visual.dart';
import 'package:alloy/core/utils/duration_format.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/player/domain/playback_state.dart';
import 'package:alloy/features/player/presentation/player_notifier.dart';
import 'package:alloy/features/player/presentation/player_panel_provider.dart';
import 'package:alloy/features/player/presentation/widgets/cover_gradient.dart';
import 'package:alloy/features/player/presentation/widgets/overflow_menu.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/no_cover_tile.dart';
import 'package:alloy/shared/widgets/seek_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Flutter also exports a RepeatMode; playback has the one that matters here.
import 'package:material_ui/material_ui.dart' hide RepeatMode;

/// Height of the panel header row that holds the close button.
const double _headerHeight = AppSizing.iconButton;

/// Full-screen now-playing sheet drawn on top of the shell.
///
/// The shell owns the slide: it translates the whole panel from below the
/// screen to full screen. Everything inside is laid out at its expanded size,
/// so the sheet always looks complete while it moves.
class NowPlayingPanel extends ConsumerWidget {
  /// Creates the panel.
  const new({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    super.key,
  });

  /// Vertical drag callbacks forwarded to the shell's controller.
  final GestureDragStartCallback onDragStart;

  /// Vertical drag update callback.
  final GestureDragUpdateCallback onDragUpdate;

  /// Vertical drag end callback.
  final GestureDragEndCallback onDragEnd;

  /// Vertical drag cancel callback.
  final GestureDragCancelCallback onDragCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider).value;
    final track = state?.track;
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;
    final safeBottom = media.padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final coverSize =
            (width.clamp(0.0, AppSizing.nowPlayingMaxWidth) - 2 * AppSpacing.xl)
                .clamp(0.0, double.infinity);
        final coverTop = safeTop + _headerHeight + AppSpacing.xxl;
        final coverLeft = (width - coverSize) / 2;

        // The top padding keeps the first line under the cover.
        final contentTop =
            coverTop + coverSize + AppSpacing.xxl - safeTop - _headerHeight;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          onVerticalDragCancel: onDragCancel,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CoverGradient(artworkRef: track?.artworkRef),
              Positioned(
                left: coverLeft,
                top: coverTop,
                width: coverSize,
                height: coverSize,
                child: _PanelCover(
                  artworkRef: track?.artworkRef,
                  size: coverSize,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: safeTop),
                child: _PanelContent(
                  state: state,
                  track: track,
                  contentTop: contentTop,
                  bottomInset: safeBottom,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Cover of the panel, drawn at the interpolated size.
///
/// The artwork is resolved once at the large variant and only its box changes,
/// so the drag never re-decodes the image frame by frame.
class _PanelCover extends ConsumerWidget {
  const new({required this.artworkRef, required this.size});

  final ArtworkRef? artworkRef;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reference = artworkRef;
    final visual = reference == null
        ? null
        : ref
              .watch(
                artworkVisualProvider((
                  artworkRef: reference,
                  size: ArtworkSize.large,
                )),
              )
              .value;

    return ClipRRect(
      borderRadius: AppRadii.artworkLarge,
      child: SizedBox.square(
        dimension: size,
        child: visual == null
            ? NoCoverTile(size: size)
            : Image.memory(
                visual.cover,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
      ),
    );
  }
}

/// Header, body and overflow menu of the expanded panel.
class _PanelContent extends ConsumerWidget {
  const new({
    required this.state,
    required this.track,
    required this.contentTop,
    required this.bottomInset,
  });

  final PlaybackState? state;
  final Track? track;
  final double contentTop;
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    void close() => ref.read(playerPanelProvider).collapse();

    return Center(
      child: ConstrainedBox(
        key: const ValueKey('now-playing-content'),
        constraints: const BoxConstraints(
          maxWidth: AppSizing.nowPlayingMaxWidth,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.sm + bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _headerHeight,
                child: _Header(
                  title: track?.album ?? l10n.nowPlaying,
                  onClose: close,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: contentTop),
                    child: track == null || state == null
                        ? const SizedBox.shrink()
                        : _PlayerBody(state: state!, track: track!),
                  ),
                ),
              ),
              if (track != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: NowPlayingOverflowMenu(
                    onStop: () =>
                        unawaited(ref.read(playerProvider.notifier).stop()),
                  ),
                ),
              ],
            ],
          ),
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
          seed: track.id.hashCode,
          onSeek: (position) => unawaited(notifier.seek(position)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Text(formatTrackDuration(state.position), style: _timeStyle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  technical ?? '',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: _timeStyle.copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
            Text(formatTrackDuration(state.duration), style: _timeStyle),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Controls(state: state),
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
          icon: Icon(context.icons.shuffle),
          color: state.shuffle ? accent : AppColors.textSecondary,
        ),
        IconButton(
          onPressed: () => unawaited(notifier.previous()),
          tooltip: l10n.previous,
          icon: Icon(context.icons.previous),
          iconSize: AppSpacing.xxl,
          color: AppColors.textPrimary,
        ),
        IconButton.filled(
          onPressed: () => unawaited(notifier.togglePlayPause()),
          tooltip: state.playing ? l10n.pause : l10n.play,
          icon: Icon(state.playing ? context.icons.pause : context.icons.play),
          iconSize: AppSpacing.xxl,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(AppSizing.nowPlayingPlayButton),
          ),
        ),
        IconButton(
          onPressed: () => unawaited(notifier.next()),
          tooltip: l10n.next,
          icon: Icon(context.icons.next),
          iconSize: AppSpacing.xxl,
          color: AppColors.textPrimary,
        ),
        IconButton(
          onPressed: () =>
              unawaited(notifier.setRepeatMode(_nextRepeat(state.repeatMode))),
          tooltip: _repeatTooltip(l10n, state.repeatMode),
          icon: Icon(
            state.repeatMode == RepeatMode.one
                ? context.icons.repeatOne
                : context.icons.repeat,
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
  const new({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          tooltip: l10n.close,
          color: AppColors.textPrimary,
          icon: Icon(context.icons.collapse),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.playerHeader.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSizing.iconButton),
      ],
    );
  }
}

final TextStyle _timeStyle = AppTextStyles.playerMeta.copyWith(
  color: AppColors.textSecondary,
);

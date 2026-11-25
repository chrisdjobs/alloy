import 'dart:math' as math;

import 'package:alloy/core/utils/duration_format.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/artwork_image.dart';
import 'package:material_ui/material_ui.dart';

/// One row of the library list.
///
/// [leading] is the artwork slot; it defaults to the track's cover and falls
/// back to the shared no-cover tile.
class TrackTile extends StatelessWidget {
  /// Creates a row for [track] that calls [onTap] when activated.
  const new({
    required this.track,
    required this.onTap,
    this.leading,
    this.showDuration = false,
    this.isCurrent = false,
    this.isPlaying = false,
    super.key,
  });

  /// Track shown in the row.
  final Track track;

  /// Opens the track in the player.
  final VoidCallback onTap;

  /// Cover slot; defaults to the track's [ArtworkImage].
  final Widget? leading;

  /// Whether the track length is written before the overflow button.
  final bool showDuration;

  /// Whether this row is the track loaded in the player.
  final bool isCurrent;

  /// Whether the loaded track is playing; only read when [isCurrent].
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final cover = leading ?? ArtworkImage(artworkRef: track.artworkRef);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          height: AppSizing.trackRow,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadii.artwork,
                child: Stack(
                  children: [
                    cover,
                    if (isCurrent)
                      Positioned.fill(
                        child: _PlayingIndicator(playing: isPlaying),
                      ),
                  ],
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
              if (showDuration)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Text(
                    formatTrackDuration(track.duration),
                    style: AppTextStyles.trackArtist.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              PopupMenuButton<_TrackAction>(
                icon: Icon(context.icons.more),
                onSelected: (_) => onTap(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _TrackAction.play,
                    child: Row(
                      children: [
                        Icon(context.icons.play, size: 18, color: accent),
                        const SizedBox(width: AppSpacing.sm),
                        Text(l10n.play),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TrackAction { play }

/// Equalizer drawn over the cover of the track loaded in the player.
///
/// The bars animate only while playback runs; a paused track keeps them still
/// so the row still says which track is loaded.
class _PlayingIndicator extends StatefulWidget {
  const new({required this.playing});

  final bool playing;

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  /// Height of each bar between the shortest and the tallest one while paused.
  static const List<double> _paused = [0.2, 1, 0.45, 0.75];

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_PlayingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.playing) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return ColoredBox(
      color: AppColors.backdropScrim,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var bar = 0; bar < _paused.length; bar++) _bar(bar, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(int index, Color accent) {
    final height =
        AppSizing.playingBarMinHeight +
        (AppSizing.playingBarMaxHeight - AppSizing.playingBarMinHeight) *
            _factor(index);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizing.playingBarGap / 2,
      ),
      child: SizedBox(
        width: AppSizing.playingBarWidth,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: accent,
            borderRadius: AppRadii.playingBar,
          ),
        ),
      ),
    );
  }

  double _factor(int index) {
    if (!widget.playing) return _paused[index];
    final wave = math.sin(
      _controller.value * 2 * math.pi + index * math.pi / 3,
    );
    return (wave + 1) / 2;
  }
}

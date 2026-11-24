import 'dart:math' as math;

import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/domain/playback_state.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:bars/shared/widgets/artwork_image.dart';
import 'package:bars/shared/widgets/bars_page_header.dart';
import 'package:bars/shared/widgets/no_tracks_state.dart';
import 'package:bars/shared/widgets/retry_message.dart';
import 'package:bars/shared/widgets/seek_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Plays [tracks] starting at [index].
typedef PlayTracksCallback = void Function(List<Track> tracks, int index);

/// Discover: a deck of the library's own tracks, one card at a time.
///
/// There is no remote catalog, so the deck deals shuffled local tracks. The
/// reference's history filters (new, forgotten, second go) need play counts
/// and are left out.
class DiscoverScreen extends StatefulWidget {
  /// Creates the discover screen.
  const new({
    required this.tracks,
    required this.playback,
    required this.onPlay,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onChooseFolder,
    required this.onRetry,
    super.key,
  });

  /// Library tracks and their load state.
  final AsyncValue<List<Track>> tracks;

  /// Current playback, used to show the live position of the dealt track.
  final PlaybackState? playback;

  /// Loads the deck and plays it at a position.
  final PlayTracksCallback onPlay;

  /// Toggles play/pause of the loaded track.
  final VoidCallback onTogglePlayPause;

  /// Seeks inside the loaded track.
  final ValueChanged<Duration> onSeek;

  /// Opens the folder picker for the empty state.
  final VoidCallback onChooseFolder;

  /// Reloads the library after a failure.
  final VoidCallback onRetry;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<Track> _deck = const [];
  List<Track>? _source;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _source = widget.tracks.value;
    _deal();
  }

  @override
  void didUpdateWidget(covariant DiscoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tracks = widget.tracks.value;
    if (!identical(tracks, _source)) {
      _source = tracks;
      _deal();
    }
  }

  void _deal() {
    final tracks = _source;
    _index = 0;
    _deck = tracks == null ? const [] : ([...tracks]..shuffle());
  }

  void _pass() {
    if (_deck.isEmpty) return;
    setState(() => _index = (_index + 1) % _deck.length);
  }

  void _reshuffle() {
    setState(() {
      _deck = [..._deck]..shuffle();
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = _deck.isEmpty ? null : _deck[_index];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarsPageHeader(
            title: l10n.discoverTitle,
            actions: [
              if (current != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    l10n.queuePosition(_index + 1, _deck.length),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: switch (widget.tracks) {
              AsyncValue(hasError: true) => RetryMessage(
                message: l10n.error,
                actionLabel: l10n.retry,
                onAction: widget.onRetry,
              ),
              AsyncValue(:final value?) when value.isEmpty => NoTracksState(
                onChooseFolder: widget.onChooseFolder,
              ),
              _ when current == null => const Center(
                child: CircularProgressIndicator(),
              ),
              _ => _Deck(
                track: current,
                position: _positionOf(current),
                playing: _isPlaying(current),
                loaded: widget.playback?.track?.id == current.id,
                onSeek: widget.onSeek,
                onPlayPause: () => _toggle(current),
                onPass: _pass,
                onReshuffle: _reshuffle,
              ),
            },
          ),
        ],
      ),
    );
  }

  Duration _positionOf(Track track) {
    final playback = widget.playback;
    return playback?.track?.id == track.id ? playback!.position : Duration.zero;
  }

  bool _isPlaying(Track track) {
    final playback = widget.playback;
    return playback?.track?.id == track.id && playback!.playing;
  }

  void _toggle(Track track) {
    if (widget.playback?.track?.id == track.id) {
      widget.onTogglePlayPause();
    } else {
      widget.onPlay(_deck, _index);
    }
  }
}

class _Deck extends StatelessWidget {
  const new({
    required this.track,
    required this.position,
    required this.playing,
    required this.loaded,
    required this.onSeek,
    required this.onPlayPause,
    required this.onPass,
    required this.onReshuffle,
  });

  final Track track;
  final Duration position;
  final bool playing;
  final bool loaded;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPlayPause;
  final VoidCallback onPass;
  final VoidCallback onReshuffle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final duration = track.duration;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) => ArtworkImage(
                artworkRef: track.artworkRef,
                size: math.min(constraints.maxWidth, AppSizing.discoverCardMax),
                borderRadius: AppRadii.artworkLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            track.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.playerTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (track.artist != null)
            Text(
              track.artist!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SeekBar(
            position: position,
            duration: loaded ? duration : null,
            seed: track.id.hashCode,
            onSeek: onSeek,
          ),
          Row(
            children: [
              Text(_formatDuration(position), style: _timeStyle),
              const Spacer(),
              Text(_durationLabel(l10n, duration), style: _timeStyle),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DeckAction(
                label: l10n.discoverReshuffle,
                icon: context.icons.shuffle,
                onTap: onReshuffle,
              ),
              _DeckAction(
                label: playing ? l10n.pause : l10n.play,
                icon: playing ? context.icons.pause : context.icons.play,
                emphasized: true,
                onTap: onPlayPause,
              ),
              _DeckAction(
                label: l10n.discoverPass,
                icon: context.icons.pass,
                onTap: onPass,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeckAction extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final size = emphasized
        ? AppSizing.discoverPlayButton
        : AppSizing.discoverActionButton;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          child: Material(
            color: emphasized ? accent : AppColors.surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox.square(
                dimension: size,
                child: Center(
                  child: Icon(
                    icon,
                    size: emphasized ? 30 : 22,
                    color: emphasized
                        ? AppColors.onAccent
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

final TextStyle _timeStyle = AppTextStyles.playerMeta.copyWith(
  color: AppColors.textSecondary,
);

/// Duration line of the deck card, e.g. "of 3:20".
String _durationLabel(AppLocalizations l10n, Duration? duration) {
  final formatted = _formatDuration(duration);
  return l10n.ofDuration(formatted);
}

String _formatDuration(Duration? duration) {
  if (duration == null) return '--:--';
  final seconds = duration.inSeconds;
  final minutes = seconds ~/ 60;
  final remainder = (seconds % 60).toString().padLeft(2, '0');
  final hours = minutes ~/ 60;
  if (hours == 0) return '$minutes:$remainder';
  return '$hours:${(minutes % 60).toString().padLeft(2, '0')}:$remainder';
}

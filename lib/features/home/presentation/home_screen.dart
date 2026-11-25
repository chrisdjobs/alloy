import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/features/home/presentation/home_callbacks.dart';
import 'package:alloy/features/home/presentation/widgets/activity_chart.dart';
import 'package:alloy/features/home/presentation/widgets/home_header.dart';
import 'package:alloy/features/home/presentation/widgets/media_carousel.dart';
import 'package:alloy/features/home/presentation/widgets/mix_carousel.dart';
import 'package:alloy/features/home/presentation/widgets/most_played_list.dart';
import 'package:alloy/features/home/presentation/widgets/statistics_card.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/no_tracks_state.dart';
import 'package:alloy/shared/widgets/retry_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Home: accent glow, quick actions, mixes, recent music and statistics.
///
/// The library stream and the playback callbacks come from the router, so this
/// feature only imports the library's domain.
class HomeScreen extends StatefulWidget {
  /// Creates the home screen.
  const new({
    required this.tracks,
    required this.onPlay,
    required this.onShuffleAll,
    required this.onChooseFolder,
    required this.onRetry,
    super.key,
  });

  /// Library tracks and their load state.
  final AsyncValue<List<Track>> tracks;

  /// Opens a track from a carousel.
  final PlayTracksCallback onPlay;

  /// Starts the whole library in shuffle mode.
  final ShuffleTracksCallback onShuffleAll;

  /// Opens the folder picker for the empty state.
  final VoidCallback onChooseFolder;

  /// Reloads the library after a failure.
  final VoidCallback onRetry;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _mixesKey = GlobalKey();
  final GlobalKey _recentKey = GlobalKey();
  final GlobalKey _albumsKey = GlobalKey();
  HomePeriod _period = HomePeriod.week;

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = widget.tracks.value;
    final tracks = value != null && value.isNotEmpty ? value : null;
    final recent = tracks == null
        ? const <Track>[]
        : recentlyAddedTracks(tracks);
    final albums = tracks == null ? const <HomeAlbum>[] : libraryAlbums(tracks);
    final mixes = tracks == null ? const <HomeMix>[] : mixesForYou(tracks);
    final played = tracks == null
        ? const <MostPlayedEntry>[]
        : mostPlayed(tracks, _period);
    final activity = activityPoints(_period);
    final statistics = tracks == null ? null : homeStatistics(tracks);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        HomeHeader(
          title: l10n.homeTitle,
          quickActions: tracks == null
              ? const []
              : [
                  QuickAccessCard(
                    label: l10n.shuffle,
                    icon: context.icons.shuffle,
                    onTap: () => widget.onShuffleAll(tracks),
                  ),
                  QuickAccessCard(
                    label: l10n.mixesForYou,
                    icon: context.icons.mixes,
                    onTap: () => _scrollTo(_mixesKey),
                  ),
                  if (albums.isNotEmpty)
                    QuickAccessCard(
                      label: l10n.libraryAlbums,
                      icon: context.icons.library,
                      onTap: () => _scrollTo(_albumsKey),
                    ),
                ],
        ),
        ...switch (widget.tracks) {
          AsyncValue(hasError: true) => [
            RetryMessage(
              message: l10n.error,
              actionLabel: l10n.retry,
              onAction: widget.onRetry,
            ),
          ],
          AsyncValue(:final value?) when value.isEmpty => [
            NoTracksState(onChooseFolder: widget.onChooseFolder),
          ],
          AsyncValue(hasValue: true) => [
            SectionHeader(key: _mixesKey, title: l10n.mixesForYou),
            MixCarousel(
              mixes: mixes,
              onPlay: (mix) => widget.onPlay(mix.tracks, 0),
            ),
            SectionHeader(key: _recentKey, title: l10n.recentlyAdded),
            TrackCarousel(tracks: recent, onPlay: widget.onPlay),
            if (albums.isNotEmpty) ...[
              SectionHeader(key: _albumsKey, title: l10n.libraryAlbums),
              AlbumCarousel(
                albums: albums,
                onPlay: (album) => widget.onPlay(album.tracks, 0),
              ),
            ],
            MostPlayedList(
              entries: played,
              period: _period,
              onPeriodChanged: (period) => setState(() => _period = period),
              onPlay: widget.onPlay,
            ),
            SectionHeader(title: l10n.activity),
            ActivityChart(points: activity, period: _period),
            SectionHeader(title: l10n.statistics),
            if (statistics != null) StatisticsCard(statistics: statistics),
            const SizedBox(height: AppSpacing.xl),
          ],
          _ => const [
            Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        },
      ],
    );
  }
}

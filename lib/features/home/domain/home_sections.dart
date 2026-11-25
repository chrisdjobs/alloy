import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/features/library/domain/track.dart';

/// An album assembled from the tracks the library already holds.
///
/// Pure Dart: the Home presentation only groups what the source reported, so
/// no album metadata is invented.
final class HomeAlbum {
  /// Creates an album.
  const new({
    required this.title,
    required this.artist,
    required this.tracks,
    required this.artworkRef,
  });

  /// Album title.
  final String title;

  /// Artist shared by the album's tracks, when known.
  final String? artist;

  /// Tracks of the album, in library order.
  final List<Track> tracks;

  /// First cover found among the tracks.
  final ArtworkRef? artworkRef;
}

/// Window used by the Home statistics sections.
enum HomePeriod {
  /// Last seven days.
  week,

  /// Last thirty days.
  month,
}

/// Kinds of generated mixes; the presentation resolves their titles.
enum HomeMixKind {
  /// What the listener plays the most right now.
  onRotation,

  /// Tracks that deserve another listen.
  deepCuts,
}

/// A generated selection of tracks shown in the "Mixes for you" carousel.
final class HomeMix {
  /// Creates a mix.
  const new({required this.kind, required this.tracks, required this.artworks});

  /// Which mix this is; drives its localized title and subtitle.
  final HomeMixKind kind;

  /// Tracks of the mix, in playback order.
  final List<Track> tracks;

  /// Up to four distinct covers of the mix, for its collage.
  final List<ArtworkRef> artworks;
}

/// One row of the "Most played" ranking.
final class MostPlayedEntry {
  /// Creates an entry.
  const new({required this.track, required this.playCount});

  /// Ranked track.
  final Track track;

  /// Number of plays inside the selected period.
  final int playCount;
}

/// One bar of the Home activity chart.
final class ActivityPoint {
  /// Creates a bar.
  const new({required this.date, required this.plays});

  /// Day the bar belongs to.
  final DateTime date;

  /// Number of plays of that day.
  final int plays;
}

/// Library totals shown by the Home statistics card.
final class HomeStatistics {
  /// Creates the totals.
  const new({
    required this.trackCount,
    required this.albumCount,
    required this.artistCount,
    required this.totalDuration,
  });

  /// Number of tracks in the library.
  final int trackCount;

  /// Number of distinct album names.
  final int albumCount;

  /// Number of distinct artist names.
  final int artistCount;

  /// Total listening length of the library.
  final Duration totalDuration;
}

/// Scaffold mixes: derived from [tracks] until the play history exists.
///
/// "On rotation" keeps every other track, "Deep cuts" walks the library
/// backwards, so both look plausible without inventing metadata.
List<HomeMix> mixesForYou(List<Track> tracks, {int limit = 10}) {
  if (tracks.isEmpty) return const [];

  HomeMix? build(HomeMixKind kind, Iterable<Track> source) {
    final selection = source.take(limit).toList(growable: false);
    if (selection.isEmpty) return null;
    return HomeMix(
      kind: kind,
      tracks: selection,
      artworks: _collageArtworks(selection),
    );
  }

  final onRotation = build(HomeMixKind.onRotation, [
    for (var i = 0; i < tracks.length; i += 2) tracks[i],
  ]);
  final deepCuts = build(HomeMixKind.deepCuts, tracks.reversed);

  return [?onRotation, ?deepCuts];
}

/// Scaffold ranking: library order with placeholder play counts.
///
/// Replace with the play-history query once the data layer records plays.
List<MostPlayedEntry> mostPlayed(
  List<Track> tracks,
  HomePeriod period, {
  int limit = 5,
}) {
  final ranked = tracks.take(limit).toList(growable: false);
  final scale = period == HomePeriod.week ? 2 : 9;
  return [
    for (var i = 0; i < ranked.length; i++)
      MostPlayedEntry(track: ranked[i], playCount: (ranked.length - i) * scale),
  ];
}

/// Scaffold activity: one bar per day with deterministic placeholder plays.
List<ActivityPoint> activityPoints(HomePeriod period, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final start = DateTime(today.year, today.month, today.day);
  final days = period == HomePeriod.week ? 7 : 30;
  return [
    for (var offset = days - 1; offset >= 0; offset--)
      ActivityPoint(
        date: start.subtract(Duration(days: offset)),
        plays: _placeholderPlays(start.subtract(Duration(days: offset))),
      ),
  ];
}

/// Library totals: real counts and length, no play history needed.
HomeStatistics homeStatistics(List<Track> tracks) {
  final albums = <String>{};
  final artists = <String>{};
  var duration = Duration.zero;
  for (final track in tracks) {
    final album = track.album?.trim();
    if (album != null && album.isNotEmpty) albums.add(album);
    final artist = track.artist?.trim();
    if (artist != null && artist.isNotEmpty) artists.add(artist);
    final length = track.duration;
    if (length != null) duration += length;
  }
  return HomeStatistics(
    trackCount: tracks.length,
    albumCount: albums.length,
    artistCount: artists.length,
    totalDuration: duration,
  );
}

int _placeholderPlays(DateTime day) => (day.day * 7 + day.month * 3) % 9;

/// Newest tracks first, capped at [limit].
///
/// Tracks without a date keep their library order at the end instead of
/// jumping to the front.
List<Track> recentlyAddedTracks(List<Track> tracks, {int limit = 12}) {
  final sorted = [...tracks]
    ..sort((left, right) {
      final leftDate = left.dateAdded;
      final rightDate = right.dateAdded;
      if (leftDate == null && rightDate == null) return 0;
      if (leftDate == null) return 1;
      if (rightDate == null) return -1;
      return rightDate.compareTo(leftDate);
    });
  return sorted.take(limit).toList(growable: false);
}

/// Albums of [tracks] sorted by title.
///
/// Tracks without an album name are skipped: they belong to no album card.
List<HomeAlbum> libraryAlbums(List<Track> tracks) {
  final grouped = <String, List<Track>>{};
  for (final track in tracks) {
    final album = track.album?.trim();
    if (album == null || album.isEmpty) continue;
    final key = '${track.artist ?? ''}\u0000$album';
    (grouped[key] ??= []).add(track);
  }

  final albums =
      [
        for (final group in grouped.values)
          HomeAlbum(
            title: group.first.album!.trim(),
            artist: group.first.artist,
            tracks: group,
            artworkRef: _firstArtwork(group),
          ),
      ]..sort(
        (left, right) =>
            left.title.toLowerCase().compareTo(right.title.toLowerCase()),
      );
  return albums;
}

ArtworkRef? _firstArtwork(List<Track> tracks) {
  for (final track in tracks) {
    final artwork = track.artworkRef;
    if (artwork != null) return artwork;
  }
  return null;
}

/// First four distinct covers of [tracks], for a mix collage.
List<ArtworkRef> _collageArtworks(List<Track> tracks) {
  final found = <ArtworkRef>[];
  final seen = <String>{};
  for (final track in tracks) {
    final artwork = track.artworkRef;
    if (artwork == null || !seen.add(artwork.hash)) continue;
    found.add(artwork);
    if (found.length == 4) break;
  }
  return found;
}

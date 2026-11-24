import 'package:bars/features/library/domain/track.dart';

/// Order of the library list.
enum TrackSort {
  /// Title, A to Z.
  titleAscending,

  /// Title, Z to A.
  titleDescending,

  /// Newest `dateAdded` first.
  recentlyAdded,

  /// Oldest `dateAdded` first.
  oldestAdded,

  /// Album name, then track number.
  album,

  /// Artist name, then title.
  artist,

  /// Shortest track first.
  duration,
}

/// Returns [tracks] ordered by [sort].
///
/// The input list is left untouched. Ties fall back to the title so the order
/// stays stable while a scan streams new rows in; tracks missing the sort key
/// go last.
List<Track> sortTracks(List<Track> tracks, TrackSort sort) {
  final ordered = [...tracks];
  switch (sort) {
    case TrackSort.titleAscending:
      ordered.sort(_byTitle);
    case TrackSort.titleDescending:
      ordered.sort((a, b) => _compareText(b.title, a.title));
    case TrackSort.recentlyAdded:
      ordered.sort(
        (a, b) => _thenByTitle(
          _compareOptional(a.dateAdded, b.dateAdded, descending: true),
          a,
          b,
        ),
      );
    case TrackSort.oldestAdded:
      ordered.sort(
        (a, b) =>
            _thenByTitle(_compareOptional(a.dateAdded, b.dateAdded), a, b),
      );
    case TrackSort.album:
      ordered.sort(_byAlbum);
    case TrackSort.artist:
      ordered.sort(_byArtist);
    case TrackSort.duration:
      ordered.sort(
        (a, b) =>
            _thenByTitle(_compareOptional(a.durationMs, b.durationMs), a, b),
      );
  }
  return ordered;
}

int _byTitle(Track a, Track b) => _compareText(a.title, b.title);

int _byAlbum(Track a, Track b) {
  final byAlbum = _compareText(a.album, b.album);
  if (byAlbum != 0) return byAlbum;
  final byNumber = _compareOptional(a.trackNumber, b.trackNumber);
  return _thenByTitle(byNumber, a, b);
}

int _byArtist(Track a, Track b) {
  final byArtist = _compareText(a.artist, b.artist);
  return _thenByTitle(byArtist, a, b);
}

int _thenByTitle(int comparison, Track a, Track b) =>
    comparison != 0 ? comparison : _byTitle(a, b);

/// Case-insensitive text order; missing values go last.
int _compareText(String? a, String? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.toLowerCase().compareTo(b.toLowerCase());
}

/// Value order; missing values go last no matter the direction.
int _compareOptional<T extends Comparable<T>>(
  T? a,
  T? b, {
  bool descending = false,
}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  final compared = a.compareTo(b);
  return descending ? -compared : compared;
}

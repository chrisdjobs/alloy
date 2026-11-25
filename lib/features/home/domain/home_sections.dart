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

import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/features/library/domain/artist.dart';
import 'package:alloy/features/library/domain/track.dart';

/// An album assembled from the tracks the library already holds.
///
/// Pure Dart: the presentation only groups what the source reported, so no
/// album metadata is invented.
final class Album {
  /// Creates an album.
  const new({
    required this.id,
    required this.title,
    required this.artist,
    required this.trackCount,
    this.artworkRef,
  });

  /// Stable key of the album: normalized artist and title.
  final String id;

  /// Album title as the first track of the group spelled it.
  final String title;

  /// Artist shared by the album's tracks, when known.
  final String? artist;

  /// Number of tracks of the album.
  final int trackCount;

  /// First cover found among the tracks.
  final ArtworkRef? artworkRef;
}

/// Normalized key that groups tracks of the same album.
String albumKey({required String? artist, required String title}) {
  return '${artistKey(artist ?? '')}\u0000${title.trim().toLowerCase()}';
}

/// Groups [tracks] by album title and artist.
///
/// Tracks without an album name are skipped: they belong to no album row.
/// Groups are sorted case-insensitively by title.
List<Album> albumsFromTracks(List<Track> tracks) {
  final grouped = <String, List<Track>>{};
  for (final track in tracks) {
    final title = track.album?.trim();
    if (title == null || title.isEmpty) continue;
    final key = albumKey(artist: track.artist, title: title);
    (grouped[key] ??= []).add(track);
  }

  final albums =
      [
        for (final entry in grouped.entries)
          Album(
            id: entry.key,
            title: entry.value.first.album!.trim(),
            artist: entry.value.first.artist,
            trackCount: entry.value.length,
            artworkRef: _firstArtwork(entry.value),
          ),
      ]..sort(
        (left, right) =>
            left.title.toLowerCase().compareTo(right.title.toLowerCase()),
      );
  return albums;
}

/// Tracks of [tracks] that belong to [album].
List<Track> albumTracks(List<Track> tracks, Album album) {
  return [
    for (final track in tracks)
      if (track.album != null &&
          albumKey(artist: track.artist, title: track.album!) == album.id)
        track,
  ];
}

ArtworkRef? _firstArtwork(List<Track> tracks) {
  for (final track in tracks) {
    final artwork = track.artworkRef;
    if (artwork != null) return artwork;
  }
  return null;
}

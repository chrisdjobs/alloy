import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/features/library/domain/track.dart';

/// An artist assembled from the tracks the library already holds.
///
/// Pure Dart: the presentation only groups what the source reported, so no
/// artist metadata is invented.
final class Artist {
  /// Creates an artist.
  const new({
    required this.id,
    required this.name,
    required this.trackCount,
    this.artworkRef,
  });

  /// Stable key of the artist: the normalized name.
  final String id;

  /// Name as the first track of the group spelled it.
  final String name;

  /// Number of tracks credited to the artist.
  final int trackCount;

  /// First cover found among the tracks.
  final ArtworkRef? artworkRef;
}

/// Normalized key that groups tracks of the same artist.
String artistKey(String name) => name.trim().toLowerCase();

/// Groups [tracks] by artist name.
///
/// Tracks without an artist name are skipped: they belong to no artist row.
/// Groups are sorted case-insensitively by name.
List<Artist> artistsFromTracks(List<Track> tracks) {
  final grouped = <String, List<Track>>{};
  for (final track in tracks) {
    final artist = track.artist?.trim();
    if (artist == null || artist.isEmpty) continue;
    (grouped[artistKey(artist)] ??= []).add(track);
  }

  final artists =
      [
        for (final entry in grouped.entries)
          Artist(
            id: entry.key,
            name: entry.value.first.artist!.trim(),
            trackCount: entry.value.length,
            artworkRef: _firstArtwork(entry.value),
          ),
      ]..sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );
  return artists;
}

/// Tracks of [tracks] credited to [artist].
List<Track> artistTracks(List<Track> tracks, Artist artist) {
  return [
    for (final track in tracks)
      if (track.artist != null && artistKey(track.artist!) == artist.id) track,
  ];
}

ArtworkRef? _firstArtwork(List<Track> tracks) {
  for (final track in tracks) {
    final artwork = track.artworkRef;
    if (artwork != null) return artwork;
  }
  return null;
}

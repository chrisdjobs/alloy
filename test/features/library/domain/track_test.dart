import 'package:bars/features/library/domain/artwork_ref.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const track = Track(
    id: 'local:/music/a.mp3',
    sourceId: 'local',
    sourceItemId: '/music/a.mp3',
    title: 'A',
    artist: 'Artist',
    album: 'Album',
    trackNumber: 1,
    durationMs: 180000,
    artworkRef: ArtworkRef('cover-hash'),
    sampleRateHz: 44100,
    bitrateKbps: 320,
    format: 'MP3',
  );

  test('compares every metadata field by value', () {
    const copy = Track(
      id: 'local:/music/a.mp3',
      sourceId: 'local',
      sourceItemId: '/music/a.mp3',
      title: 'A',
      artist: 'Artist',
      album: 'Album',
      trackNumber: 1,
      durationMs: 180000,
      artworkRef: ArtworkRef('cover-hash'),
      sampleRateHz: 44100,
      bitrateKbps: 320,
      format: 'MP3',
    );

    expect(track, copy);
    expect(track.hashCode, copy.hashCode);
    expect(track, isNot(track.copyWith(title: 'B')));
  });

  test('copyWith replaces one field and keeps the rest', () {
    final renamed = track.copyWith(artist: 'Other');

    expect(renamed.artist, 'Other');
    expect(renamed.title, track.title);
    expect(renamed.artworkRef, track.artworkRef);
    expect(renamed.durationMs, track.durationMs);
  });

  test('duration is derived from durationMs', () {
    expect(track.duration, const Duration(minutes: 3));
    expect(track.copyWith(durationMs: null).duration, isNull);
  });

  test('artwork refs are opaque content hashes', () {
    expect(const ArtworkRef('abc'), const ArtworkRef('abc'));
    expect(const ArtworkRef('abc'), isNot(const ArtworkRef('def')));
    expect(const ArtworkRef('abc').hash, 'abc');
  });
}

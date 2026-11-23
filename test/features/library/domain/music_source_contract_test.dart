import 'package:bars/core/platform/local_audio_files.dart';
import 'package:bars/features/library/data/database/app_database.dart';
import 'package:bars/features/library/data/local_music_source.dart';
import 'package:bars/features/library/domain/music_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_local_audio_files.dart';

/// Checks the guarantees every [MusicSource] owes the library layer.
///
/// The cases run against the local source; a new source (Jellyfin later) has
/// to pass the same expectations before bootstrap wires it in.
void main() {
  late AppDatabase database;
  late FakeLocalAudioFiles files;
  late MusicSource source;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    files = FakeLocalAudioFiles()
      ..folders['/music'] = [
        _tags('/music/a.mp3', title: 'A'),
        _tags('/music/b.mp3', title: 'B'),
      ];
    source = LocalMusicSource(database: database, files: files);
  });

  tearDown(() => database.close());

  test('listTracks emits an empty list before the first scan', () async {
    expect(await source.listTracks().first, isEmpty);
  });

  test('stamps its id on every stored track', () async {
    await source.scan('/music').drain<void>();

    final tracks = await source.listTracks().first;

    expect(tracks, hasLength(2));
    expect(tracks.map((track) => track.sourceId), everyElement(source.id));
    expect(source.id, isNotEmpty);
  });

  test('scan reports monotonic progress and closes complete', () async {
    final events = await source.scan('/music').toList();

    expect(events, isNotEmpty);
    var lastRead = -1;
    for (final event in events) {
      expect(event.filesFound, 2);
      expect(event.filesRead, greaterThanOrEqualTo(lastRead));
      lastRead = event.filesRead;
    }
    expect(events.first.filesRead, 0);
    expect(events.last.filesRead, 2);
    expect(events.last.isComplete, isTrue);
  });

  test('resolveUri addresses the stored source item', () async {
    await source.scan('/music').drain<void>();
    final track = (await source.listTracks().first).first;

    final uri = source.resolveUri(track);

    expect(uri.isScheme('file'), isTrue);
    expect(uri.toFilePath(), track.sourceItemId);
  });
}

LocalAudioTags _tags(String path, {required String title}) {
  return LocalAudioTags(
    path: path,
    title: title,
    artist: 'Artist',
    album: 'Album',
    durationMs: 180000,
    sampleRateHz: 44100,
    bitrateKbps: 320,
    format: 'MP3',
  );
}

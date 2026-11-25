import 'dart:io';

import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/platform/local_audio_files.dart';
import 'package:alloy/features/library/data/database/app_database.dart';
import 'package:alloy/features/library/data/local_music_source.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_local_audio_files.dart';

void main() {
  late AppDatabase database;
  late FakeLocalAudioFiles files;
  late LocalMusicSource source;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    files = FakeLocalAudioFiles();
    source = LocalMusicSource(database: database, files: files);
  });

  tearDown(() => database.close());

  test('scans a folder, stores tracks and reports progress', () async {
    files.folders['/music'] = [
      _tags('/music/a.mp3', title: 'A', trackNumber: 1),
      _tags('/music/b.flac', title: 'B', sampleRateHz: 96000),
    ];

    final events = await source.scan('/music').toList();

    expect(events.first.filesFound, 2);
    expect(events.first.filesRead, 0);
    expect(events.last.filesRead, 2);
    expect(events.last.isComplete, isTrue);
    expect(files.readCalls, hasLength(1));

    final tracks = await source.listTracks().first;
    expect(tracks.map((track) => track.title), ['A', 'B']);
    expect(tracks.first.sourceId, LocalMusicSource.sourceId);
    expect(tracks.first.sourceItemId, '/music/a.mp3');
    expect(tracks.first.trackNumber, 1);
    expect(tracks.first.bitrateKbps, 320);
    expect(tracks.first.format, 'MP3');
    expect(tracks.first.artworkRef, isNull);
    expect(tracks.last.sampleRateHz, 96000);
  });

  test('stores the artwork hash read from the tags', () async {
    files.folders['/music'] = [
      _tags('/music/a.mp3', title: 'A', artworkRef: 'cover-hash'),
    ];

    await source.scan('/music').drain<void>();
    final track = (await source.listTracks().first).single;

    expect(track.artworkRef, const ArtworkRef('cover-hash'));
  });

  test('rescanning updates rows instead of duplicating them', () async {
    files.folders['/music'] = [_tags('/music/a.mp3', title: 'Old')];
    await source.scan('/music').drain<void>();
    final first = await source.listTracks().first;

    files.folders['/music'] = [_tags('/music/a.mp3', title: 'New')];
    await source.scan('/music').drain<void>();
    final second = await source.listTracks().first;

    expect(second, hasLength(1));
    expect(second.single.title, 'New');
    expect(second.single.id, first.single.id);
  });

  test('an empty folder completes with zero files', () async {
    files.folders['/empty'] = [];

    final events = await source.scan('/empty').toList();

    expect(events, hasLength(1));
    expect(events.single.filesFound, 0);
    expect(events.single.isComplete, isTrue);
    expect(await source.listTracks().first, isEmpty);
  });

  test('emits stored tracks to new subscribers', () async {
    files.folders['/music'] = [_tags('/music/a.mp3', title: 'A')];
    await source.scan('/music').drain<void>();

    final emitted = <List<Object>>[];
    final subscription = source.listTracks().listen(emitted.add);
    await pumpEventQueue();

    expect(emitted, hasLength(1));
    expect(emitted.single, hasLength(1));
    await subscription.cancel();
  });

  test('resolves a track to its file URI', () {
    final track = sourceTrack('/music/a b.mp3');

    expect(source.resolveUri(track), Uri.file('/music/a b.mp3'));
  });

  test('a file system failure ends the scan with an error', () async {
    files
      ..folders['/music'] = [_tags('/music/a.mp3', title: 'A')]
      ..readError = const FileSystemException('unreadable');

    expect(source.scan('/music').toList(), throwsA(isA<FileSystemException>()));
  });
}

LocalAudioTags _tags(
  String path, {
  required String title,
  int? trackNumber,
  int? sampleRateHz,
  String? artworkRef,
}) {
  return LocalAudioTags(
    path: path,
    title: title,
    artist: 'Artist',
    album: 'Album',
    trackNumber: trackNumber,
    durationMs: 180000,
    sampleRateHz: sampleRateHz ?? 44100,
    bitrateKbps: 320,
    format: path.endsWith('.flac') ? 'FLAC' : 'MP3',
    artworkRef: artworkRef,
  );
}

Track sourceTrack(String path) => Track(
  id: 'local:$path',
  sourceId: 'local',
  sourceItemId: path,
  title: 'Title',
);

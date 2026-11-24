import 'dart:io';

import 'package:bars/core/failure.dart';
import 'package:bars/core/platform/audio_permission.dart';
import 'package:bars/core/platform/folder_store.dart';
import 'package:bars/core/platform/local_audio_files.dart';
import 'package:bars/features/library/data/database/app_database.dart';
import 'package:bars/features/library/data/library_repository_impl.dart';
import 'package:bars/features/library/data/local_music_source.dart';
import 'package:bars/features/library/domain/music_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_audio_permission.dart';
import '../../../fakes/fake_folder_picker.dart';
import '../../../fakes/fake_local_audio_files.dart';

void main() {
  late AppDatabase database;
  late FakeLocalAudioFiles files;
  late FakeFolderPicker picker;
  late FakeAudioPermission permission;
  late LibraryRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    files = FakeLocalAudioFiles();
    picker = FakeFolderPicker();
    permission = FakeAudioPermission();
    repository = LibraryRepositoryImpl(
      source: LocalMusicSource(database: database, files: files),
      folderPicker: picker,
      permission: permission,
      folderStore: const NoopFolderStore(),
    );
  });

  tearDown(() async {
    await repository.dispose();
    await database.close();
  });

  test(
    'scanFolder picks a folder, asks permission and stores tracks',
    () async {
      files.folders['/music'] = [_tags('/music/a.mp3'), _tags('/music/b.flac')];
      picker.folder = '/music';
      final progress = <ScanProgress>[];
      final subscription = repository.scanProgress.listen(progress.add);
      addTearDown(subscription.cancel);

      final result = await repository.scanFolder();
      await pumpEventQueue();

      expect(result.isOk, isTrue);
      expect(picker.calls, 1);
      expect(permission.calls, 1);
      expect(progress, isNotEmpty);
      expect(progress.last.isComplete, isTrue);
      expect(progress.last.filesRead, 2);

      final tracks = await repository.tracksStream().first;
      expect(tracks, hasLength(2));
    },
  );

  test('cancelling the picker finishes without scanning', () async {
    final result = await repository.scanFolder();

    expect(result.isOk, isTrue);
    expect(picker.calls, 1);
    expect(permission.calls, 0);
    expect(files.readCalls, isEmpty);
  });

  test('denied permission fails the scan before reading files', () async {
    files.folders['/music'] = [_tags('/music/a.mp3')];
    picker.folder = '/music';
    permission.status = AudioPermissionStatus.denied;

    final result = await repository.scanFolder();

    expect(result.failureOrNull, isA<PermissionFailure>());
    expect(files.readCalls, isEmpty);
    expect(await repository.tracksStream().first, isEmpty);
  });

  test('triggerScan rescans the last folder without the picker', () async {
    files.folders['/music'] = [_tags('/music/a.mp3')];
    picker.folder = '/music';
    await repository.scanFolder();

    files.folders['/music'] = [_tags('/music/a.mp3', title: 'Renamed')];
    await repository.triggerScan();

    expect(picker.calls, 1);
    final tracks = await repository.tracksStream().first;
    expect(tracks.single.title, 'Renamed');
  });

  test('triggerScan falls back to the picker before any folder', () async {
    files.folders['/music'] = [_tags('/music/a.mp3')];
    picker.folder = '/music';

    final result = await repository.triggerScan();

    expect(result.isOk, isTrue);
    expect(picker.calls, 1);
    expect(await repository.tracksStream().first, hasLength(1));
  });

  test('track stream emits after the scan writes tracks', () async {
    files.folders['/music'] = [_tags('/music/a.mp3')];
    picker.folder = '/music';
    final emitted = <List<Object>>[];
    final subscription = repository.tracksStream().listen(emitted.add);
    addTearDown(subscription.cancel);

    await repository.scanFolder();
    await pumpEventQueue();

    expect(emitted, isNotEmpty);
    expect(emitted.last, hasLength(1));
  });

  test('a scanner error returns an io failure and closes progress', () async {
    files
      ..folders['/music'] = [_tags('/music/a.mp3')]
      ..readError = const FileSystemException('unreadable');
    picker.folder = '/music';
    final progress = <ScanProgress>[];
    final subscription = repository.scanProgress.listen(progress.add);
    addTearDown(subscription.cancel);

    final result = await repository.scanFolder();
    await pumpEventQueue();

    expect(result.failureOrNull, isA<IoFailure>());
    expect(progress.last.isComplete, isTrue);
  });
}

LocalAudioTags _tags(String path, {String title = 'Title'}) {
  return LocalAudioTags(
    path: path,
    title: title,
    artist: 'Artist',
    album: 'Album',
    durationMs: 180000,
    sampleRateHz: 44100,
    bitrateKbps: 320,
    format: path.endsWith('.flac') ? 'FLAC' : 'MP3',
  );
}

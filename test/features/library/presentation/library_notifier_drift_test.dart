import 'package:bars/core/platform/local_audio_files.dart';
import 'package:bars/features/library/data/database/app_database.dart';
import 'package:bars/features/library/data/library_repository_impl.dart';
import 'package:bars/features/library/data/local_music_source.dart';
import 'package:bars/features/library/presentation/library_notifier.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_audio_permission.dart';
import '../../../fakes/fake_folder_picker.dart';
import '../../../fakes/fake_local_audio_files.dart';

/// Wires the notifier to the real repository over an in-memory database.
void main() {
  late AppDatabase database;
  late FakeLocalAudioFiles files;
  late FakeFolderPicker picker;
  late LibraryRepositoryImpl repository;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
    files = FakeLocalAudioFiles();
    picker = FakeFolderPicker()..folder = '/music';
    repository = LibraryRepositoryImpl(
      source: LocalMusicSource(database: database, files: files),
      folderPicker: picker,
      permission: FakeAudioPermission(),
    );
    container = ProviderContainer.test(
      overrides: [libraryRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    await repository.dispose();
    await database.close();
  });

  test('starts empty and fills the state after a scan', () async {
    files.folders['/music'] = [_tags('/music/a.mp3', title: 'A')];

    expect(await container.read(libraryProvider.future), isEmpty);

    await container.read(libraryProvider.notifier).scanFolder();
    await pumpEventQueue();

    final tracks = container.read(libraryProvider).requireValue;
    expect(tracks.single.title, 'A');
  });

  test('triggerScan refreshes the tracks after the tags change', () async {
    files.folders['/music'] = [_tags('/music/a.mp3', title: 'Old')];
    await container.read(libraryProvider.future);
    await container.read(libraryProvider.notifier).scanFolder();
    await pumpEventQueue();

    files.folders['/music'] = [_tags('/music/a.mp3', title: 'New')];
    await container.read(libraryProvider.notifier).triggerScan();
    await pumpEventQueue();

    final tracks = container.read(libraryProvider).requireValue;
    expect(tracks.single.title, 'New');
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

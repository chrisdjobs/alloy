import 'package:bars/core/failure.dart';
import 'package:bars/core/result.dart';
import 'package:bars/features/library/domain/music_source.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/library/presentation/library_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_library_repository.dart';

void main() {
  late FakeLibraryRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeLibraryRepository();
    container = ProviderContainer.test(
      overrides: [libraryRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => repository.dispose());

  test('builds from the current tracks', () async {
    repository.tracks = [_track('a')];

    final tracks = await container.read(libraryProvider.future);

    expect(tracks.single.title, 'a');
  });

  test('emits updated tracks to the UI', () async {
    await container.read(libraryProvider.future);

    repository.emitTracks([_track('a'), _track('b')]);
    await pumpEventQueue();

    final state = container.read(libraryProvider);
    expect(state.requireValue, hasLength(2));
  });

  test('scanFolder calls the repository', () async {
    await container.read(libraryProvider.future);

    await container.read(libraryProvider.notifier).scanFolder();

    expect(repository.scanFolderCalls, 1);
    expect(container.read(libraryProvider).hasError, isFalse);
  });

  test('triggerScan calls the repository', () async {
    await container.read(libraryProvider.future);

    await container.read(libraryProvider.notifier).triggerScan();

    expect(repository.triggerScanCalls, 1);
  });

  test('a failed scan surfaces an error state', () async {
    await container.read(libraryProvider.future);
    repository.scanFolderResult = const Err<void>(
      Failure.permission(message: 'denied'),
    );

    await container.read(libraryProvider.notifier).scanFolder();

    final state = container.read(libraryProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<PermissionFailure>());
  });

  test('a track stream error surfaces an error state', () async {
    await container.read(libraryProvider.future);

    repository.emitError(StateError('database gone'));
    await pumpEventQueue();

    expect(container.read(libraryProvider).hasError, isTrue);
  });

  test('forwards scan progress', () async {
    final states = <AsyncValue<ScanProgress>>[];
    final subscription = container.listen(
      scanProgressProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await pumpEventQueue();

    repository.emitScanProgress(
      const ScanProgress(filesFound: 3, filesRead: 1),
    );
    await pumpEventQueue();

    expect(
      container.read(scanProgressProvider).requireValue,
      const ScanProgress(filesFound: 3, filesRead: 1),
    );

    repository.emitScanProgress(
      const ScanProgress(filesFound: 3, filesRead: 3, isComplete: true),
    );
    await pumpEventQueue();

    expect(
      container.read(scanProgressProvider).requireValue.isComplete,
      isTrue,
    );
    expect(states.first, isA<AsyncLoading<ScanProgress>>());
  });
}

Track _track(String title) => Track(
  id: 'local:/music/$title.mp3',
  sourceId: 'local',
  sourceItemId: '/music/$title.mp3',
  title: title,
);

import 'package:bars/core/failure.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/domain/playback_state.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_playback_engine.dart';

void main() {
  late FakePlaybackEngine engine;
  late ProviderContainer container;

  setUp(() {
    engine = FakePlaybackEngine();
    container = ProviderContainer.test(
      overrides: [playbackEngineProvider.overrideWithValue(engine)],
    );
  });

  tearDown(() => engine.dispose());

  test('builds from the engine snapshot', () async {
    final state = await container.read(playerProvider.future);

    expect(state.playing, isFalse);
    expect(state.track, isNull);
    expect(state.processingState, PlaybackProcessingState.idle);
  });

  test('loadQueueAndPlay loads the queue and starts playback', () async {
    await container.read(playerProvider.future);
    final tracks = [_track('a'), _track('b')];

    await container.read(playerProvider.notifier).loadQueueAndPlay(tracks, 1);
    await pumpEventQueue();

    expect(engine.queue, tracks);
    expect(engine.initialIndex, 1);
    expect(engine.playCalls, 1);

    final state = container.read(playerProvider).requireValue;
    expect(state.playing, isTrue);
    expect(state.queueIndex, 1);
    expect(state.track?.id, 'b');
  });

  test('merges position and track events into the state', () async {
    await container.read(playerProvider.future);

    engine
      ..emitPosition(const Duration(seconds: 42))
      ..emitTrack(_track('c'));
    await pumpEventQueue();

    final state = container.read(playerProvider).requireValue;
    expect(state.position, const Duration(seconds: 42));
    expect(state.track?.id, 'c');
  });

  test('togglePlayPause pauses while playing', () async {
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadQueueAndPlay([_track('a')], 0);
    await pumpEventQueue();
    await notifier.togglePlayPause();
    await pumpEventQueue();

    expect(engine.pauseCalls, 1);
    expect(container.read(playerProvider).requireValue.playing, isFalse);

    await notifier.togglePlayPause();
    await pumpEventQueue();

    expect(engine.playCalls, 2);
    expect(container.read(playerProvider).requireValue.playing, isTrue);
  });

  test('next, previous and seek reach the engine', () async {
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);
    await notifier.loadQueueAndPlay([_track('a'), _track('b')], 0);
    await pumpEventQueue();

    await notifier.next();
    await notifier.previous();
    await notifier.seek(const Duration(seconds: 5));

    expect(engine.skipNextCalls, 1);
    expect(engine.skipPreviousCalls, 1);
    expect(engine.seeks, [const Duration(seconds: 5)]);
    expect(container.read(playerProvider).requireValue.queueIndex, 0);
  });

  test('a failing command surfaces an AsyncError', () async {
    await container.read(playerProvider.future);
    engine.nextFailure = const Failure.unknown(message: 'broken');

    await container.read(playerProvider.notifier).next();
    await pumpEventQueue();

    final state = container.read(playerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<UnknownFailure>());
    expect(engine.skipNextCalls, 0);
  });
}

Track _track(String id, {int? durationMs = 180000}) {
  return Track(
    id: id,
    sourceId: 'local',
    sourceItemId: '/music/$id.mp3',
    title: 'Track $id',
    artist: 'Artist',
    album: 'Album',
    durationMs: durationMs,
  );
}

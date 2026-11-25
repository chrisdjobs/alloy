import 'dart:typed_data';

import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/artwork/artwork_visual.dart';
import 'package:alloy/features/library/data/artwork_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_artwork_store.dart';

void main() {
  late FakeArtworkStore store;
  late ArtworkCache cache;

  setUp(() {
    store = FakeArtworkStore();
    cache = ArtworkCache(store: store);
  });

  test('a miss returns null', () async {
    expect(await cache.read('missing'), isNull);
  });

  test('a hit returns the stored bytes and marks them as used', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    await cache.write('cover', bytes);

    expect(await cache.read('cover'), bytes);
    expect(store.touches, ['cover']);
  });

  test('tracks sharing a hash share one cache entry', () async {
    const first = ArtworkRef('album-hash');
    const second = ArtworkRef('album-hash');

    final firstKey = ArtworkCache.coverKey(first, ArtworkSize.small);
    final secondKey = ArtworkCache.coverKey(second, ArtworkSize.small);
    expect(firstKey, secondKey);

    await cache.write(firstKey, Uint8List(8));
    await cache.write(secondKey, Uint8List(8));

    expect(store.files, hasLength(1));
    expect(await cache.read(firstKey), isNotNull);
  });

  test('sizes and metadata get separate keys', () {
    const ref = ArtworkRef('hash');

    expect({
      ArtworkCache.coverKey(ref, ArtworkSize.small),
      ArtworkCache.coverKey(ref, ArtworkSize.large),
      ArtworkCache.metaKey(ref),
    }, hasLength(3));
  });

  test('eviction removes the least recently used entries first', () async {
    cache = ArtworkCache(store: store, maxBytes: 10);

    store.now = DateTime(2026, 2);
    await cache.write('old', Uint8List(6));
    store.now = DateTime(2026, 3);
    await cache.write('new', Uint8List(6));

    await cache.trim();

    expect(store.files.keys, ['new']);
    expect(store.deletes, ['old']);
  });

  test('reading an entry protects it from eviction', () async {
    cache = ArtworkCache(store: store, maxBytes: 10);

    store.now = DateTime(2026, 2);
    await cache.write('first', Uint8List(6));
    store.now = DateTime(2026, 3);
    await cache.write('second', Uint8List(6));

    store.now = DateTime(2026, 4);
    await cache.read('first');
    await cache.trim();

    expect(store.files.keys, ['first']);
    expect(store.deletes, ['second']);
  });

  test('writes larger than the cap are not cached', () async {
    cache = ArtworkCache(store: store, maxBytes: 4);

    await cache.write('huge', Uint8List(5));

    expect(store.files, isEmpty);
  });
}

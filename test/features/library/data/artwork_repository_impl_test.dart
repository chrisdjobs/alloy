import 'dart:async';
import 'dart:typed_data';

import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/features/library/data/artwork_cache.dart';
import 'package:bars/features/library/data/artwork_repository_impl.dart';
import 'package:bars/shared/design/cover_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../../../fakes/fake_artwork_store.dart';

void main() {
  late FakeArtworkStore store;
  late ArtworkCache cache;
  late Uint8List coverBytes;
  const reference = ArtworkRef('cover-hash');

  setUp(() {
    store = FakeArtworkStore();
    cache = ArtworkCache(store: store);
    coverBytes = img.encodeJpg(
      img.Image(width: 12, height: 12)..clear(img.ColorRgb8(140, 40, 30)),
    );
  });

  test('extracts every variant once and caches it', () async {
    var loads = 0;
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async {
        loads++;
        return coverBytes;
      },
    );

    final visual = await repository.visualFor(reference, ArtworkSize.small);

    expect(visual, isNotNull);
    expect(visual!.cover, isNotEmpty);
    expect(visual.backdrop, isNotEmpty);
    expect(
      CoverColors.contrastRatio(
        visual.backdropColorArgb,
        CoverColors.defaultTextArgb,
      ),
      greaterThanOrEqualTo(CoverColors.minContrast),
    );
    expect(loads, 1);
    expect(
      store.files.keys,
      containsAll([
        ArtworkCache.coverKey(reference, ArtworkSize.small),
        ArtworkCache.coverKey(reference, ArtworkSize.large),
        ArtworkCache.metaKey(reference),
      ]),
    );
  });

  test('a disk hit does not read the source again', () async {
    await ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async => coverBytes,
    ).visualFor(reference, ArtworkSize.small);

    var loads = 0;
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async {
        loads++;
        return coverBytes;
      },
    );

    final visual = await repository.visualFor(reference, ArtworkSize.small);

    expect(visual, isNotNull);
    expect(loads, 0);
  });

  test('both sizes come from one extraction', () async {
    var loads = 0;
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async {
        loads++;
        return coverBytes;
      },
    );

    final small = await repository.visualFor(reference, ArtworkSize.small);
    final large = await repository.visualFor(reference, ArtworkSize.large);

    expect(loads, 1);
    expect(small!.cover, isNot(large!.cover));
  });

  test('concurrent requests share one extraction', () async {
    final source = Completer<Uint8List?>();
    var loads = 0;
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) {
        loads++;
        return source.future;
      },
    );

    final first = repository.visualFor(reference, ArtworkSize.small);
    final second = repository.visualFor(reference, ArtworkSize.small);
    source.complete(coverBytes);

    expect(await first, isNotNull);
    expect(await second, isNotNull);
    expect(loads, 1);
  });

  test('a track without cover bytes has no visual', () async {
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async => null,
    );

    expect(await repository.visualFor(reference, ArtworkSize.small), isNull);
    expect(store.files, isEmpty);
  });

  test('undecodable bytes have no visual', () async {
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async => Uint8List.fromList([1, 2, 3, 4]),
    );

    expect(await repository.visualFor(reference, ArtworkSize.small), isNull);
  });

  test('a failing source has no visual and does not throw', () async {
    final repository = ArtworkRepositoryImpl(
      cache: cache,
      loadBytes: (_) async => throw StateError('gone'),
    );

    expect(await repository.visualFor(reference, ArtworkSize.small), isNull);
  });
}

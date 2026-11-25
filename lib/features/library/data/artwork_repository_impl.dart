import 'dart:typed_data';

import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/artwork/artwork_visual.dart';
import 'package:alloy/core/logger.dart';
import 'package:alloy/features/library/data/artwork_cache.dart';
import 'package:alloy/features/library/data/cover_extractor.dart';

/// [ArtworkRepository] that extracts covers once and caches every variant.
///
/// Extraction runs in an isolate; sizes, backdrop and dominant color land on
/// disk, so scrolling never decodes the same album twice.
final class ArtworkRepositoryImpl implements ArtworkRepository {
  /// Creates the repository.
  new({
    required this.cache,
    required this.loadBytes,
    this.extractor = const CoverExtractor(),
    this.memoryCapacity = 32,
  });

  /// Disk cache for extracted variants.
  final ArtworkCache cache;

  /// Source-specific loader of the raw cover bytes behind a reference.
  final ArtworkBytesLoader loadBytes;

  /// Decoder and color extractor.
  final CoverExtractor extractor;

  /// Extracted visuals kept in memory; disk misses are the expensive case.
  final int memoryCapacity;

  final _memory = <String, ArtworkVisual>{};
  final _inFlight = <String, Future<ArtworkVisual?>>{};

  @override
  Future<ArtworkVisual?> visualFor(ArtworkRef ref, ArtworkSize size) {
    final key = '${ref.hash}_${size.name}';
    final cached = _memory[key];
    if (cached != null) return Future.value(cached);

    final pending = _inFlight[key];
    if (pending != null) return pending;

    final future = _load(key, ref, size);
    _inFlight[key] = future;
    // removeWhere instead of remove: returning the stored future from the
    // callback would make whenComplete wait on the future it completes.
    return future.whenComplete(
      () => _inFlight.removeWhere((pending, _) => pending == key),
    );
  }

  Future<ArtworkVisual?> _load(
    String key,
    ArtworkRef ref,
    ArtworkSize size,
  ) async {
    try {
      final cover = await cache.read(ArtworkCache.coverKey(ref, size));
      final meta = await cache.read(ArtworkCache.metaKey(ref));
      if (cover != null && meta != null) {
        final visual = _decode(cover, meta);
        if (visual != null) return _remember(key, visual);
      }

      final bytes = await loadBytes(ref);
      if (bytes == null) return null;

      final extracted = await extractor.extract(bytes);
      if (extracted == null) return null;

      final metaBytes = _encodeMeta(extracted);
      await cache.write(
        ArtworkCache.coverKey(ref, ArtworkSize.small),
        extracted.small,
      );
      await cache.write(
        ArtworkCache.coverKey(ref, ArtworkSize.large),
        extracted.large,
      );
      await cache.write(ArtworkCache.metaKey(ref), metaBytes);

      final coverBytes = size == ArtworkSize.small
          ? extracted.small
          : extracted.large;
      final visual = _decode(coverBytes, metaBytes);
      return visual == null ? null : _remember(key, visual);
    } on Object catch (error, stackTrace) {
      Logger.error(
        'Could not extract artwork',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  ArtworkVisual? _decode(Uint8List cover, Uint8List meta) {
    if (meta.length < _metaHeaderLength) return null;
    final color = ByteData.sublistView(meta, 0, _metaHeaderLength).getUint32(0);
    return ArtworkVisual(
      cover: cover,
      backdrop: Uint8List.sublistView(meta, _metaHeaderLength),
      backdropColorArgb: color,
    );
  }

  Uint8List _encodeMeta(ExtractedArtwork extracted) {
    final data = ByteData(_metaHeaderLength + extracted.backdrop.length)
      ..setUint32(0, extracted.backdropColorArgb);
    final bytes = data.buffer.asUint8List();
    bytes.setRange(_metaHeaderLength, bytes.length, extracted.backdrop);
    return bytes;
  }

  ArtworkVisual _remember(String key, ArtworkVisual visual) {
    _memory
      ..remove(key)
      ..[key] = visual;
    while (_memory.length > memoryCapacity) {
      _memory.remove(_memory.keys.first);
    }
    return visual;
  }
}

/// Big-endian dominant color followed by the blurred backdrop bytes.
const _metaHeaderLength = 4;

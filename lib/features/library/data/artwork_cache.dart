import 'dart:typed_data';

import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';
import 'package:bars/core/platform/artwork_store.dart';

/// Size-capped, least-recently-used disk cache for extracted artwork.
///
/// Keys combine the artwork hash with the variant, so two tracks of one album
/// share a single entry and eviction never leaves a half-written variant.
final class ArtworkCache {
  /// Creates a cache over [store] holding at most [maxBytes] of artwork.
  new({required this.store, this.maxBytes = defaultMaxBytes});

  /// Default cap: roughly 400 albums with both thumbnail sizes cached.
  static const int defaultMaxBytes = 64 << 20;

  /// Entries written before an eviction pass runs again.
  static const int _trimAfterWrites = 24;

  /// Bytes written before an eviction pass runs again.
  static const int _trimAfterBytes = 4 << 20;

  /// Byte storage, swapped for an in-memory fake in tests.
  final ArtworkStore store;

  /// Maximum total size of all cached files.
  final int maxBytes;

  var _writesSinceTrim = 0;
  var _bytesSinceTrim = 0;

  /// Cache key of the cover for [ref] at [size].
  static String coverKey(ArtworkRef ref, ArtworkSize size) {
    return '${ref.hash}_${size.name}';
  }

  /// Cache key of the dominant color and blurred backdrop of [ref].
  static String metaKey(ArtworkRef ref) => '${ref.hash}_meta';

  /// Reads [key], marking it as recently used.
  Future<Uint8List?> read(String key) async {
    final bytes = await store.read(key);
    if (bytes != null) await store.touch(key);
    return bytes;
  }

  /// Writes [key] and evicts least-recently-used entries when over the cap.
  Future<void> write(String key, Uint8List bytes) async {
    if (bytes.length > maxBytes) return;
    await store.write(key, bytes);
    _writesSinceTrim++;
    _bytesSinceTrim += bytes.length;
    if (_writesSinceTrim >= _trimAfterWrites ||
        _bytesSinceTrim >= _trimAfterBytes) {
      await trim();
    }
  }

  /// Deletes least-recently-used files until the cache fits [maxBytes].
  Future<void> trim() async {
    _writesSinceTrim = 0;
    _bytesSinceTrim = 0;
    final entries = await store.list();
    var total = entries.fold(0, (sum, entry) => sum + entry.length);
    if (total <= maxBytes) return;

    entries.sort((a, b) => a.lastUsed.compareTo(b.lastUsed));
    for (final entry in entries) {
      if (total <= maxBytes) break;
      await store.delete(entry.key);
      total -= entry.length;
    }
  }
}

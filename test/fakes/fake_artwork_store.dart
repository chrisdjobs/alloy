import 'dart:typed_data';

import 'package:bars/core/platform/artwork_store.dart';

/// In-memory [ArtworkStore] with controllable timestamps for LRU tests.
final class FakeArtworkStore implements ArtworkStore {
  /// Stored files by key.
  final Map<String, Uint8List> files = {};

  /// Last-used timestamp per key; set [now] before writing or touching.
  final Map<String, DateTime> lastUsed = {};

  /// Keys read through [touch], in call order.
  final List<String> touches = [];

  /// Keys removed through [delete], in call order.
  final List<String> deletes = [];

  /// Timestamp assigned by the next write or touch.
  DateTime now = DateTime(2026);

  @override
  Future<Uint8List?> read(String key) async => files[key];

  @override
  Future<void> write(String key, Uint8List bytes) async {
    files[key] = bytes;
    lastUsed[key] = now;
  }

  @override
  Future<void> delete(String key) async {
    files.remove(key);
    lastUsed.remove(key);
    deletes.add(key);
  }

  @override
  Future<void> touch(String key) async {
    if (!files.containsKey(key)) return;
    touches.add(key);
    lastUsed[key] = now;
  }

  @override
  Future<List<ArtworkStoreEntry>> list() async {
    return [
      for (final entry in files.entries)
        ArtworkStoreEntry(
          key: entry.key,
          length: entry.value.length,
          lastUsed: lastUsed[entry.key] ?? now,
        ),
    ];
  }
}

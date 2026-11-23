import 'dart:typed_data';

/// One file in an [ArtworkStore].
final class ArtworkStoreEntry {
  /// Creates an entry for [key].
  const new({required this.key, required this.length, required this.lastUsed});

  /// Cache key of the file.
  final String key;

  /// Size in bytes.
  final int length;

  /// Last read or write, used to evict the least recently used entry.
  final DateTime lastUsed;
}

/// Byte storage for the artwork cache.
///
/// The cache policy lives in the library feature; only the file access is
/// platform code, so tests can swap in an in-memory store.
abstract interface class ArtworkStore {
  /// Returns the bytes stored under [key], or null on a miss.
  Future<Uint8List?> read(String key);

  /// Stores [bytes] under [key], replacing an existing entry.
  Future<void> write(String key, Uint8List bytes);

  /// Removes [key] if it exists.
  Future<void> delete(String key);

  /// Marks [key] as just used so eviction keeps it around.
  Future<void> touch(String key);

  /// Lists every stored entry.
  Future<List<ArtworkStoreEntry>> list();
}

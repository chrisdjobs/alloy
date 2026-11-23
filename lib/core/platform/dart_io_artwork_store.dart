import 'dart:io';
import 'dart:typed_data';

import 'package:bars/core/platform/artwork_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// [ArtworkStore] backed by files in the app cache directory.
final class DartIoArtworkStore implements ArtworkStore {
  /// Stores files in a subdirectory of the application cache.
  new({String folder = 'artwork'}) : _folderName = folder;

  final String _folderName;
  Directory? _folder;

  @override
  Future<Uint8List?> read(String key) async {
    final file = await _file(key);
    if (!file.existsSync()) return null;
    return await file.readAsBytes();
  }

  @override
  Future<void> write(String key, Uint8List bytes) async {
    final file = await _file(key);
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> delete(String key) async {
    final file = await _file(key);
    if (file.existsSync()) await file.delete();
  }

  @override
  Future<void> touch(String key) async {
    final file = await _file(key);
    if (file.existsSync()) await file.setLastModified(DateTime.now());
  }

  @override
  Future<List<ArtworkStoreEntry>> list() async {
    final folder = await _directory();
    final entries = <ArtworkStoreEntry>[];
    // Listing and stats stay async so they never block a frame.
    await for (final entity in folder.list(followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.bin')) continue;
      // The async stat keeps the listing off the UI isolate.
      // ignore: avoid_slow_async_io
      final stat = await entity.stat();
      entries.add(
        ArtworkStoreEntry(
          key: p.basenameWithoutExtension(entity.path),
          length: stat.size,
          lastUsed: stat.modified,
        ),
      );
    }
    return entries;
  }

  Future<File> _file(String key) async {
    if (!_validKey.hasMatch(key)) {
      throw ArgumentError.value(key, 'key', 'Not a valid artwork cache key');
    }
    return File(p.join((await _directory()).path, '$key.bin'));
  }

  Future<Directory> _directory() async {
    final cached = _folder;
    if (cached != null) return cached;
    final base = await getApplicationCacheDirectory();
    final folder = Directory(p.join(base.path, _folderName));
    await folder.create(recursive: true);
    return _folder = folder;
  }
}

/// Keys are hashes and size suffixes produced by the artwork cache.
final _validKey = RegExp(r'^[a-zA-Z0-9_-]+$');

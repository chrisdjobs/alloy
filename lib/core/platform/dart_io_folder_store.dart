import 'dart:io';

import 'package:alloy/core/logger.dart';
import 'package:alloy/core/platform/folder_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// [FolderStore] backed by a small file in the app support directory.
///
/// A file is enough for one string; a Drift table would need a schema
/// migration for the same value.
final class DartIoFolderStore implements FolderStore {
  /// Creates the store.
  const new();

  static const _fileName = 'library_folder.txt';

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File(p.join(directory.path, _fileName));
  }

  @override
  Future<String?> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return null;
      final folder = (await file.readAsString()).trim();
      return folder.isEmpty ? null : folder;
    } on Exception catch (error, stackTrace) {
      Logger.error(
        'Could not read the last music folder',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> save(String folder) async {
    try {
      await (await _file()).writeAsString(folder, flush: true);
    } on Exception catch (error, stackTrace) {
      // Losing the memory only costs one extra folder pick.
      Logger.error(
        'Could not store the music folder',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      final file = await _file();
      if (file.existsSync()) await file.delete();
    } on Exception catch (error, stackTrace) {
      Logger.error(
        'Could not clear the music folder',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

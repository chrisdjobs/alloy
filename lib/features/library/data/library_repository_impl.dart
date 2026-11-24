import 'dart:async';

import 'package:bars/core/failure.dart';
import 'package:bars/core/platform/audio_permission.dart';
import 'package:bars/core/platform/folder_picker.dart';
import 'package:bars/core/platform/folder_store.dart';
import 'package:bars/core/result.dart';
import 'package:bars/features/library/domain/library_repository.dart';
import 'package:bars/features/library/domain/music_source.dart';
import 'package:bars/features/library/domain/track.dart';

/// [LibraryRepository] backed by one [MusicSource] and the platform pickers.
final class LibraryRepositoryImpl implements LibraryRepository {
  /// Creates the repository.
  new({
    required this.source,
    required this.folderPicker,
    required this.permission,
    required this.folderStore,
  });

  /// Source that scans and stores tracks.
  final MusicSource source;

  /// Picker for the music folder.
  final FolderPicker folderPicker;

  /// Runtime permission needed before reading audio files.
  final AudioPermission permission;

  /// Remembers the scanned folder, so a restart can rescan without the picker.
  final FolderStore folderStore;

  final _scanProgress = StreamController<ScanProgress>.broadcast();
  String? _lastFolder;
  bool _scanning = false;

  @override
  Stream<List<Track>> tracksStream() => source.listTracks();

  @override
  Stream<ScanProgress> get scanProgress => _scanProgress.stream;

  @override
  Future<Result<void>> scanFolder() async {
    final String? folder;
    try {
      folder = await folderPicker.pickFolder();
    } on Exception catch (error, stackTrace) {
      return Err(
        Failure.io(
          message: 'Could not open the folder picker',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
    if (folder == null) return const Ok<void>(null);
    return await _scan(folder);
  }

  @override
  Future<Result<void>> triggerScan() async {
    final remembered = _lastFolder ?? await folderStore.read();
    if (remembered == null) return await scanFolder();
    final result = await _scan(remembered);
    // A folder that no longer exists must not trap every rescan; forget it so
    // the next tap opens the picker again.
    if (result.failureOrNull is IoFailure) {
      _lastFolder = null;
      await folderStore.clear();
    }
    return result;
  }

  /// Releases the progress stream.
  Future<void> dispose() => _scanProgress.close();

  Future<Result<void>> _scan(String folder) async {
    if (_scanning) {
      return const Err(
        Failure.unknown(message: 'A library scan is already running'),
      );
    }

    _scanning = true;
    try {
      final status = await permission.request();
      if (status != AudioPermissionStatus.granted) {
        return Err(
          Failure.permission(
            message: status == AudioPermissionStatus.permanentlyDenied
                ? 'Audio access was permanently denied'
                : 'Audio access was denied',
          ),
        );
      }

      _lastFolder = folder;
      await folderStore.save(folder);
      var latest = const ScanProgress(filesFound: 0, filesRead: 0);
      try {
        await for (final progress in source.scan(folder)) {
          latest = progress;
          _scanProgress.add(progress);
        }
      } on Exception catch (error, stackTrace) {
        if (!latest.isComplete) {
          _scanProgress.add(latest.copyWith(isComplete: true));
        }
        return Err(
          Failure.io(
            message: 'Could not scan $folder',
            cause: error,
            stackTrace: stackTrace,
          ),
        );
      }
      if (!latest.isComplete) {
        _scanProgress.add(latest.copyWith(isComplete: true));
      }
      return const Ok<void>(null);
    } finally {
      _scanning = false;
    }
  }
}

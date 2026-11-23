import 'package:bars/core/result.dart';
import 'package:bars/features/library/domain/music_source.dart';
import 'package:bars/features/library/domain/track.dart';

/// Library-facing view of the music sources.
///
/// The UI reads tracks as a stream and asks for scans; it never talks to a
/// source or to the database directly.
abstract interface class LibraryRepository {
  /// Emits the stored tracks on subscribe and after every change.
  Stream<List<Track>> tracksStream();

  /// Emits scan progress for the whole session.
  Stream<ScanProgress> get scanProgress;

  /// Opens the folder picker and scans the chosen folder.
  ///
  /// Completes with [Ok] when the scan finished or the picker was cancelled.
  Future<Result<void>> scanFolder();

  /// Rescans the last chosen folder without opening the picker.
  ///
  /// Falls back to [scanFolder] when no folder has been chosen yet.
  Future<Result<void>> triggerScan();
}

import 'dart:async';

import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/domain/album.dart';
import 'package:alloy/features/library/domain/artist.dart';
import 'package:alloy/features/library/domain/library_repository.dart';
import 'package:alloy/features/library/domain/music_source.dart';
import 'package:alloy/features/library/domain/track.dart';

/// In-memory [LibraryRepository] for notifier and widget tests.
final class FakeLibraryRepository implements LibraryRepository {
  final _tracks = StreamController<List<Track>>.broadcast();
  final _progress = StreamController<ScanProgress>.broadcast();

  /// Tracks emitted to new subscribers.
  List<Track> tracks = const [];

  /// Result returned by [scanFolder].
  Result<void> scanFolderResult = const Ok<void>(null);

  /// Result returned by [triggerScan].
  Result<void> triggerScanResult = const Ok<void>(null);

  /// Number of [scanFolder] calls.
  int scanFolderCalls = 0;

  /// Number of [triggerScan] calls.
  int triggerScanCalls = 0;

  /// Whether [dispose] ran.
  bool disposed = false;

  /// When true, [tracksStream] never emits the initial tracks.
  bool neverEmits = false;

  /// When set, [tracksStream] fails before emitting anything.
  Object? initialError;

  @override
  Stream<List<Track>> tracksStream() async* {
    if (initialError != null) {
      yield* Stream.error(initialError!);
      return;
    }
    if (!neverEmits) yield tracks;
    yield* _tracks.stream;
  }

  @override
  Stream<List<Artist>> artistsStream() => tracksStream().map(artistsFromTracks);

  @override
  Stream<List<Album>> albumsStream() => tracksStream().map(albumsFromTracks);

  @override
  Stream<ScanProgress> get scanProgress => _progress.stream;

  @override
  Future<Result<void>> scanFolder() async {
    scanFolderCalls++;
    return scanFolderResult;
  }

  @override
  Future<Result<void>> triggerScan() async {
    triggerScanCalls++;
    return triggerScanResult;
  }

  /// Replaces the current tracks and emits them to subscribers.
  void emitTracks(List<Track> next) {
    tracks = List.unmodifiable(next);
    _tracks.add(tracks);
  }

  /// Emits a scan progress event.
  void emitScanProgress(ScanProgress progress) => _progress.add(progress);

  /// Emits an error on the track stream.
  void emitError(Object error, [StackTrace? stackTrace]) =>
      _tracks.addError(error, stackTrace);

  /// Releases the controllers.
  Future<void> dispose() async {
    disposed = true;
    await _tracks.close();
    await _progress.close();
  }
}

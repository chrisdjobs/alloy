import 'dart:async';

import 'package:alloy/core/logger.dart';
import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/domain/library_repository.dart';
import 'package:alloy/features/library/domain/music_source.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_notifier.g.dart';

/// Repository behind the library; bootstrap overrides it with the local one.
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  throw UnimplementedError(
    'libraryRepositoryProvider must be overridden during bootstrap',
  );
});

/// Exposes the stored tracks and scan actions to the UI.
@Riverpod(keepAlive: true)
class LibraryNotifier extends _$LibraryNotifier {
  @override
  Future<List<Track>> build() async {
    final repository = ref.watch(libraryRepositoryProvider);
    var ready = false;
    var disposed = false;

    final subscription = repository.tracksStream().listen(
      (tracks) {
        if (ready && !disposed) state = AsyncData(tracks);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (ready && !disposed) state = AsyncError(error, stackTrace);
      },
    );

    ref.onDispose(() {
      disposed = true;
      unawaited(subscription.cancel());
    });

    final initial = await repository.tracksStream().first;
    ready = true;
    return initial;
  }

  /// Opens the folder picker and scans the chosen folder.
  Future<void> scanFolder() => _scan((repository) => repository.scanFolder());

  /// Rescans the last folder, picking one when none was chosen yet.
  Future<void> triggerScan() => _scan((repository) => repository.triggerScan());

  Future<void> _scan(
    Future<Result<void>> Function(LibraryRepository repository) action,
  ) async {
    final failure = (await action(ref.read(libraryRepositoryProvider)))
        .failureOrNull;
    if (failure == null) return;
    Logger.error(
      failure.message ?? 'Library scan failed',
      error: failure.cause,
      stackTrace: failure.stackTrace,
    );
    state = AsyncError(failure, failure.stackTrace ?? StackTrace.current);
  }
}

/// Progress of the running scan; the last event carries `isComplete: true`.
@Riverpod(keepAlive: true)
Stream<ScanProgress> scanProgress(Ref ref) {
  return ref.watch(libraryRepositoryProvider).scanProgress;
}

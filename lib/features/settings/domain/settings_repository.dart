import 'dart:async';

import 'package:alloy/core/result.dart';
import 'package:alloy/features/settings/domain/app_settings.dart';

/// Storage for [AppSettings].
///
/// Implementations read the persisted values once during startup and then keep
/// [current] in memory, so the UI can render synchronously.
abstract interface class SettingsRepository {
  /// Latest settings; defaults until [load] completes.
  AppSettings get current;

  /// Loads the persisted settings into [current].
  Future<void> load();

  /// Emits the new settings after every successful [save].
  Stream<AppSettings> get changes;

  /// Persists [settings] and emits it on [changes].
  Future<Result<void>> save(AppSettings settings);
}

/// [SettingsRepository] that keeps everything in memory.
///
/// It is the fallback when a host does not provide persistence, which keeps
/// widgets and tests working without a database, like `NoopFolderStore` does
/// for the library folder.
final class InMemorySettingsRepository implements SettingsRepository {
  /// Creates the repository, starting from [initial].
  new({AppSettings initial = const AppSettings()}) : _current = initial;

  final _changes = StreamController<AppSettings>.broadcast();
  AppSettings _current;

  @override
  AppSettings get current => _current;

  @override
  Stream<AppSettings> get changes => _changes.stream;

  @override
  Future<void> load() async {}

  @override
  Future<Result<void>> save(AppSettings settings) async {
    _current = settings;
    _changes.add(settings);
    return const Ok<void>(null);
  }
}

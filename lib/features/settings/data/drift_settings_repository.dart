import 'dart:async';

import 'package:bars/core/failure.dart';
import 'package:bars/core/result.dart';
import 'package:bars/features/settings/data/database/settings_database.dart';
import 'package:bars/features/settings/data/settings_codec.dart';
import 'package:bars/features/settings/domain/app_settings.dart';
import 'package:bars/features/settings/domain/settings_repository.dart';

/// [SettingsRepository] backed by the settings database.
final class DriftSettingsRepository implements SettingsRepository {
  /// Creates the repository around [database].
  new({required this.database});

  /// Database that stores the key/value rows.
  final SettingsDatabase database;

  final _changes = StreamController<AppSettings>.broadcast();
  AppSettings _current = const AppSettings();

  @override
  AppSettings get current => _current;

  @override
  Stream<AppSettings> get changes => _changes.stream;

  @override
  Future<void> load() async {
    final rows = await database.select(database.settingsEntries).get();
    _current = SettingsCodec.decode({
      for (final row in rows) row.settingKey: row.value,
    });
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    try {
      final entries = SettingsCodec.encode(settings);
      await database.batch((batch) {
        // Replacing the rows keeps cleared values (such as a null accent)
        // from lingering as stale keys.
        batch
          ..deleteAll(database.settingsEntries)
          ..insertAll(database.settingsEntries, [
            for (final entry in entries.entries)
              SettingsEntriesCompanion.insert(
                settingKey: entry.key,
                value: entry.value,
              ),
          ]);
      });
    } on Exception catch (error, stackTrace) {
      return Err(
        Failure.io(
          message: 'Could not save the settings',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
    _current = settings;
    _changes.add(settings);
    return const Ok<void>(null);
  }

  /// Closes the change stream; call it when the database closes.
  Future<void> dispose() => _changes.close();
}

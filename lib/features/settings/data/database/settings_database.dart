import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'settings_database.g.dart';

/// Preferences database, separate from the library database.
@DriftDatabase(include: {'tables/settings_entries.drift'})
final class SettingsDatabase extends _$SettingsDatabase {
  /// Opens the app preferences file.
  new() : super(_openConnection());

  /// Opens [e] instead of the app database; used by tests.
  new withExecutor(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'alloy_settings');
}

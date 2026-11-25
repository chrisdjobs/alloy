import 'package:alloy/features/library/data/database/migrations.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Local SQLite library shared by every music source.
///
/// `driftDatabase` opens the file through `NativeDatabase.createInBackground`,
/// so queries run on a background isolate, and it points sqlite at an
/// app-owned temporary directory (the Android sandbox has no usable `/tmp`).
@DriftDatabase(
  include: {
    'tables/tracks.drift',
    'tables/artists.drift',
    'tables/albums.drift',
  },
)
final class AppDatabase extends _$AppDatabase {
  /// Opens the app database file.
  new() : super(_openConnection());

  /// Opens [e] instead of the app database; used by tests.
  new withExecutor(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => buildMigrationStrategy();

  static QueryExecutor _openConnection() => driftDatabase(name: 'alloy');
}

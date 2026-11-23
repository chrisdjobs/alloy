import 'package:drift/drift.dart';

/// Migration plan for the library database.
///
/// Version history:
/// - 1: tracks, artists and albums. `tracks.artwork_ref` is reserved from the
///   start (nullable content hash) so Phase 6 only populates it through a
///   proper version bump instead of reshaping the table.
/// - 2+: reserved for album/artist browsing and artwork population.
///
/// Never edit an existing step: published database versions must replay
/// exactly. Add a new version and a new step instead.
MigrationStrategy buildMigrationStrategy() {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      // No upgrade steps yet: version 1 is the first published schema.
    },
  );
}

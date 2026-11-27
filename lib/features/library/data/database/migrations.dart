import 'package:drift/drift.dart';

/// Migration plan for the library database.
///
/// Version history:
/// - 1: tracks, artists and albums. `tracks.artwork_ref` is reserved from the
///   start (nullable content hash) so artwork only needed a version bump to be
///   populated, not a table reshape.
/// - 2: index on `tracks.artwork_ref`. Covers are resolved by hash, so all
///   tracks of one album share one cached image; scans fill the column
///   (existing libraries pick it up on the next rescan).
/// - 3: `tracks.lyrics`, the lyrics tag of the file. Stored so the player can
///   read them on demand instead of holding them in every `Track`; existing
///   libraries fill the column on the next rescan.
/// - 4+: reserved for future browsing.
///
/// Never edit an existing step: published database versions must replay
/// exactly. Add a new version and a new step instead.
MigrationStrategy buildMigrationStrategy() {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.database.customStatement(
          'CREATE INDEX tracks_artwork_ref_idx ON tracks (artwork_ref)',
        );
      }
      if (from < 3) {
        await migrator.database.customStatement(
          'ALTER TABLE tracks ADD COLUMN lyrics TEXT',
        );
      }
    },
  );
}

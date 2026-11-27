import 'package:alloy/features/library/data/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('version 1 upgrades to the latest schema keeping tracks', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute('''
      INSERT INTO tracks (id, source_id, source_item_id, title)
      VALUES ('local:/music/a.mp3', 'local', '/music/a.mp3', 'Kept')
    ''');

    final database = AppDatabase.withExecutor(schema.newConnection());
    await verifier.migrateAndValidate(database, 3);

    final rows = await database.select(database.tracks).get();
    expect(rows.single.title, 'Kept');
    expect(rows.single.artworkRef, isNull);
    expect(rows.single.lyrics, isNull);
    expect(database.schemaVersion, 3);

    final indexes = await database
        .customSelect(
          'SELECT name FROM sqlite_master '
          "WHERE type = 'index' AND name = 'tracks_artwork_ref_idx'",
        )
        .get();
    expect(indexes, hasLength(1));

    await database.close();
    schema.close();
  });
}

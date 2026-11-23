import 'package:bars/features/library/data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('schema version 2 creates the library tables and index', () async {
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        )
        .get();
    final names = rows.map((row) => row.read<String>('name'));

    expect(names, containsAll(['tracks', 'artists', 'albums']));

    final indexes = await database
        .customSelect(
          'SELECT name FROM sqlite_master '
          "WHERE type = 'index' AND name = 'tracks_artwork_ref_idx'",
        )
        .get();
    expect(indexes, hasLength(1));
  });

  test('inserts a track and applies date_added default', () async {
    await database
        .into(database.tracks)
        .insert(
          TracksCompanion.insert(
            id: 'local:/music/a.flac',
            sourceId: 'local',
            sourceItemId: '/music/a.flac',
            title: 'A',
            sampleRateHz: const Value(44100),
            bitrateKbps: const Value(920),
            format: const Value('FLAC'),
          ),
        );

    final row = await database.select(database.tracks).getSingle();

    expect(row.title, 'A');
    expect(row.artworkRef, isNull);
    expect(row.sampleRateHz, 44100);
    expect(row.bitrateKbps, 920);
    expect(row.format, 'FLAC');
    expect(
      row.dateAdded.difference(DateTime.now()).inMinutes.abs(),
      lessThan(1),
    );
  });

  test('upsert updates metadata without resetting date_added', () async {
    Future<void> write(String title) {
      return database
          .into(database.tracks)
          .insertOnConflictUpdate(
            TracksCompanion.insert(
              id: 'local:/music/a.flac',
              sourceId: 'local',
              sourceItemId: '/music/a.flac',
              title: title,
            ),
          );
    }

    await write('Old title');
    final first = await database.select(database.tracks).getSingle();

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await write('New title');
    final second = await database.select(database.tracks).getSingle();

    expect(second.title, 'New title');
    expect(second.dateAdded, first.dateAdded);
    expect(await database.select(database.tracks).get(), hasLength(1));
  });
}

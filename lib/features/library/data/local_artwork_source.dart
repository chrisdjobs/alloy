import 'dart:typed_data';

import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/platform/local_cover_reader.dart';
import 'package:alloy/features/library/data/database/app_database.dart';
import 'package:drift/drift.dart';

/// Supplies local cover bytes for an artwork reference.
///
/// The reference is a content hash, so any track carrying it can be used to
/// re-read the bytes: all tracks of an album share one cover.
final class LocalArtworkSource {
  /// Creates the source over the library [database] and [reader].
  new({required this.database, required this.reader});

  /// Library database that maps hashes back to files.
  final AppDatabase database;

  /// Reader that opens the tags or the folder image.
  final LocalCoverReader reader;

  /// Returns the cover behind [ref], or null when no track has it.
  Future<Uint8List?> coverBytes(ArtworkRef ref) async {
    final query = database.select(database.tracks)
      ..where((row) => row.artworkRef.equals(ref.hash))
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return await reader.coverFor(row.sourceItemId);
  }
}

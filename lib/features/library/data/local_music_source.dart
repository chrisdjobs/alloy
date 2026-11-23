import 'dart:math';

import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/platform/local_audio_files.dart';
import 'package:bars/features/library/data/database/app_database.dart';
import 'package:bars/features/library/domain/music_source.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:drift/drift.dart';

/// [MusicSource] that scans folders on the local file system.
///
/// Tags are read off the UI thread by [LocalAudioFiles] and written in batches
/// so a 10k-track folder does not lock the database per file.
final class LocalMusicSource implements MusicSource {
  /// Creates the source around the library [database] and file [files].
  new({required this.database, required this.files});

  /// Source id stored on every local track.
  static const sourceId = 'local';

  /// Files written per database batch.
  static const _writeBatchSize = 50;

  /// Library database that stores the scanned tracks.
  final AppDatabase database;

  /// Reader for audio files on this platform.
  final LocalAudioFiles files;

  @override
  String get id => sourceId;

  @override
  Stream<ScanProgress> scan(String folderPath) async* {
    final paths = await files.listAudioFiles(folderPath);
    if (paths.isEmpty) {
      yield const ScanProgress(filesFound: 0, filesRead: 0, isComplete: true);
      return;
    }

    yield ScanProgress(filesFound: paths.length, filesRead: 0);
    var read = 0;
    for (var start = 0; start < paths.length; start += _writeBatchSize) {
      final batch = paths.sublist(
        start,
        min(start + _writeBatchSize, paths.length),
      );
      final tags = await files.readTags(batch);
      await database.batch((batch) {
        batch.insertAllOnConflictUpdate(database.tracks, [
          for (final tag in tags) _toCompanion(tag),
        ]);
      });
      read += tags.length;
      yield ScanProgress(
        filesFound: paths.length,
        filesRead: read,
        isComplete: read >= paths.length,
      );
    }
  }

  @override
  Stream<List<Track>> listTracks() {
    final query = database.select(database.tracks)
      ..orderBy([
        (row) => OrderingTerm(expression: row.title.collate(Collate.noCase)),
      ]);
    return query.watch().map(
      (rows) => rows.map(_toTrack).toList(growable: false),
    );
  }

  @override
  Uri resolveUri(Track track) => Uri.file(track.sourceItemId);

  TracksCompanion _toCompanion(LocalAudioTags tags) {
    return TracksCompanion.insert(
      id: '$sourceId:${tags.path}',
      sourceId: sourceId,
      sourceItemId: tags.path,
      title: tags.title,
      artist: Value(tags.artist),
      album: Value(tags.album),
      trackNumber: Value(tags.trackNumber),
      durationMs: Value(tags.durationMs),
      sampleRateHz: Value(tags.sampleRateHz),
      bitrateKbps: Value(tags.bitrateKbps),
      format: Value(tags.format),
      artworkRef: Value(tags.artworkRef),
      // dateAdded is absent so a rescan keeps the original value.
    );
  }

  Track _toTrack(TrackRow row) {
    return Track(
      id: row.id,
      sourceId: row.sourceId,
      sourceItemId: row.sourceItemId,
      title: row.title,
      artist: row.artist,
      album: row.album,
      trackNumber: row.trackNumber,
      durationMs: row.durationMs,
      artworkRef: row.artworkRef == null ? null : ArtworkRef(row.artworkRef!),
      sampleRateHz: row.sampleRateHz,
      bitrateKbps: row.bitrateKbps,
      format: row.format,
    );
  }
}

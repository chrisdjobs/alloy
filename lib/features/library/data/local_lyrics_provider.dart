import 'package:alloy/core/failure.dart';
import 'package:alloy/core/result.dart';
import 'package:alloy/features/library/data/database/app_database.dart';
import 'package:alloy/features/library/domain/lyrics_provider.dart';
import 'package:alloy/features/library/domain/track.dart';

/// [LyricsProvider] backed by the local library database.
///
/// Reads the `lyrics` column stored during scan; online providers can implement
/// the same contract later without touching the player.
final class LocalLyricsProvider implements LyricsProvider {
  /// Creates the provider around [database].
  const new({required this.database});

  /// Library database that stores tracks and their lyrics.
  final AppDatabase database;

  @override
  Future<Result<String?>> lyricsFor(Track track) async {
    try {
      final row = await (database.select(
        database.tracks,
      )..where((t) => t.id.equals(track.id))).getSingleOrNull();
      if (row == null) {
        return const Err(
          Failure.notFound(message: 'Track not found in the database'),
        );
      }
      return Ok<String?>(row.lyrics);
    } on Exception catch (error, stackTrace) {
      return Err(
        Failure.io(
          message: 'Could not read lyrics for ${track.id}',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

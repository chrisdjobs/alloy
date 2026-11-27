import 'package:alloy/features/library/domain/lyrics_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lyrics provider; bootstrap overrides it with the local database one.
final lyricsProvider = Provider<LyricsProvider>((ref) {
  throw UnimplementedError(
    'lyricsProvider must be overridden during bootstrap',
  );
});

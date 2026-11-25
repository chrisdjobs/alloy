import 'dart:async';

import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/artwork/artwork_visual.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'artwork_providers.g.dart';

/// Repository behind artwork; bootstrap overrides it with the local pipeline.
final artworkRepositoryProvider = Provider<ArtworkRepository>((ref) {
  throw UnimplementedError(
    'artworkRepositoryProvider must be overridden during bootstrap',
  );
});

/// One cover request: an opaque reference at a resolution.
typedef ArtworkRequest = ({ArtworkRef artworkRef, ArtworkSize size});

/// Cover behind [request], loaded off the UI thread and cached.
///
/// Kept alive for a short scroll window so rows that leave and re-enter the
/// viewport do not reload; the repository's bounded memory cache absorbs the
/// rest, so a large library never pins every image in memory.
@riverpod
Future<ArtworkVisual?> artworkVisual(Ref ref, ArtworkRequest request) {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);
  return ref
      .watch(artworkRepositoryProvider)
      .visualFor(request.artworkRef, request.size);
}

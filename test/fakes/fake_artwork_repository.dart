import 'package:bars/core/artwork/artwork_ref.dart';
import 'package:bars/core/artwork/artwork_visual.dart';

/// In-memory [ArtworkRepository] for widget tests.
final class FakeArtworkRepository implements ArtworkRepository {
  /// Visuals returned per reference and size.
  final Map<ArtworkRef, Map<ArtworkSize, ArtworkVisual>> visuals = {};

  /// When set, [visualFor] fails with it.
  Exception? error;

  /// Requests received, in call order.
  final List<(ArtworkRef, ArtworkSize)> requests = [];

  @override
  Future<ArtworkVisual?> visualFor(ArtworkRef ref, ArtworkSize size) async {
    requests.add((ref, size));
    final failure = error;
    if (failure != null) throw failure;
    return visuals[ref]?[size];
  }
}

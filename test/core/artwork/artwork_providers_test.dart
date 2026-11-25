import 'package:alloy/core/artwork/artwork_providers.dart';
import 'package:alloy/core/artwork/artwork_ref.dart';
import 'package:alloy/core/artwork/artwork_visual.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/cover_test_image.dart';
import '../../fakes/fake_artwork_repository.dart';

void main() {
  FakeArtworkRepository repositoryFor(List<ArtworkSize> sizes) {
    return FakeArtworkRepository()
      ..visuals[const ArtworkRef('a')] = {
        for (final size in sizes)
          size: ArtworkVisual(
            cover: testCoverBytes,
            backdrop: testCoverBytes,
            backdropColorArgb: 0xFF101010,
          ),
      };
  }

  test('repeated reads of one request hit the repository once', () async {
    final repository = repositoryFor([ArtworkSize.small]);
    final container = ProviderContainer(
      overrides: [artworkRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    const request = (artworkRef: ArtworkRef('a'), size: ArtworkSize.small);

    final first = await container.read(artworkVisualProvider(request).future);
    final second = await container.read(artworkVisualProvider(request).future);

    expect(first, isNotNull);
    expect(second, same(first));
    expect(repository.requests, hasLength(1));
  });

  test('the two sizes are separate requests', () async {
    final repository = repositoryFor(ArtworkSize.values);
    final container = ProviderContainer(
      overrides: [artworkRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(
      artworkVisualProvider((
        artworkRef: const ArtworkRef('a'),
        size: ArtworkSize.small,
      )).future,
    );
    await container.read(
      artworkVisualProvider((
        artworkRef: const ArtworkRef('a'),
        size: ArtworkSize.large,
      )).future,
    );

    expect(repository.requests, hasLength(2));
  });
}

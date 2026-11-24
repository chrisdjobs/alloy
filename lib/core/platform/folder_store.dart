/// Remembers the last music folder between sessions.
///
/// Without it, "rescan" after an app start has to open the folder picker
/// again, because the folder only lived in memory.
abstract interface class FolderStore {
  /// Returns the last scanned folder, or null when none is stored.
  Future<String?> read();

  /// Stores [folder] as the folder to rescan next time.
  Future<void> save(String folder);

  /// Forgets the stored folder; the next rescan asks for one.
  Future<void> clear();
}

/// [FolderStore] that remembers nothing, for hosts without persistence.
final class NoopFolderStore implements FolderStore {
  /// Creates the store.
  const new();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> save(String folder) async {}

  @override
  Future<void> clear() async {}
}

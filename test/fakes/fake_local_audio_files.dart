import 'package:bars/core/platform/local_audio_files.dart';

/// In-memory [LocalAudioFiles] for scanner tests.
final class FakeLocalAudioFiles implements LocalAudioFiles {
  /// Tags available per folder path, as a real file listing would report.
  final Map<String, List<LocalAudioTags>> folders = {};

  /// Paths passed to [readTags], in call order.
  final List<List<String>> readCalls = [];

  /// Runs before tags are returned; use it to simulate I/O failures.
  Exception? readError;

  @override
  Future<List<String>> listAudioFiles(String folderPath) async {
    final tags = folders[folderPath];
    if (tags == null) {
      throw StateError('Unknown folder $folderPath');
    }
    return [for (final tag in tags) tag.path];
  }

  @override
  Future<List<LocalAudioTags>> readTags(List<String> paths) async {
    readCalls.add(List.unmodifiable(paths));
    final error = readError;
    if (error != null) throw error;
    final byPath = {
      for (final folder in folders.values)
        for (final tag in folder) tag.path: tag,
    };
    return [
      for (final path in paths)
        byPath[path] ??
            LocalAudioTags(
              path: path,
              title: path.split('/').last.split('.').first,
            ),
    ];
  }
}

import 'dart:isolate';
import 'dart:typed_data';

import 'package:alloy/core/platform/cover_files.dart';
import 'package:alloy/core/platform/local_cover_reader.dart';

/// [LocalCoverReader] that re-reads tags in a background isolate.
final class DartIoLocalCoverReader implements LocalCoverReader {
  /// Creates the reader.
  const new();

  @override
  Future<Uint8List?> coverFor(String audioFilePath) {
    return Isolate.run(() => readLocalCoverBytes(audioFilePath));
  }
}

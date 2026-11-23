import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

/// Folder image names accepted as a fallback cover, in priority order.
const folderCoverNames = ['cover', 'folder', 'front'];

/// Folder image extensions accepted as a fallback cover, in priority order.
const folderCoverExtensions = ['.jpg', '.jpeg', '.png'];

/// Picks the embedded front cover, falling back to the first picture.
Uint8List? embeddedCover(List<Picture> pictures) {
  if (pictures.isEmpty) return null;
  for (final picture in pictures) {
    if (picture.pictureType == PictureType.coverFront) return picture.bytes;
  }
  return pictures.first.bytes;
}

/// Reads the cover embedded in [audioFilePath], if any.
///
/// Failures are expected for damaged files and simply mean "no cover".
Uint8List? readEmbeddedCover(String audioFilePath) {
  try {
    // The reader skips embedded images unless asked, and covers are the point.
    return embeddedCover(
      readMetadata(File(audioFilePath), getImage: true).pictures,
    );
  } on Exception {
    return null;
  }
}

/// Read folder covers, cached per folder for the duration of a scan batch.
///
/// Tags without a picture still get the album art stored next to the file.
Uint8List? folderCoverBytes(
  String audioFilePath, {
  Map<String, Uint8List?>? cache,
}) {
  final folder = p.dirname(audioFilePath);
  if (cache != null && cache.containsKey(folder)) return cache[folder];
  final bytes = _readFolderCover(folder);
  cache?[folder] = bytes;
  return bytes;
}

/// Cover for [audioFilePath]: embedded first, then the folder image.
Uint8List? readLocalCoverBytes(String audioFilePath) {
  return readEmbeddedCover(audioFilePath) ?? folderCoverBytes(audioFilePath);
}

Uint8List? _readFolderCover(String folder) {
  final directory = Directory(folder);
  if (!directory.existsSync()) return null;

  String? bestPath;
  var bestPriority = folderCoverNames.length * folderCoverExtensions.length;
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is! File) continue;
    final name = p.basenameWithoutExtension(entity.path).toLowerCase();
    final nameIndex = folderCoverNames.indexOf(name);
    final extensionIndex = folderCoverExtensions.indexOf(
      p.extension(entity.path).toLowerCase(),
    );
    if (nameIndex < 0 || extensionIndex < 0) continue;
    final priority = nameIndex * folderCoverExtensions.length + extensionIndex;
    if (priority < bestPriority) {
      bestPriority = priority;
      bestPath = entity.path;
    }
  }
  if (bestPath == null) return null;
  try {
    return File(bestPath).readAsBytesSync();
  } on FileSystemException {
    return null;
  }
}

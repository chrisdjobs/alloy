import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:alloy/core/platform/cover_files.dart';
import 'package:alloy/core/platform/local_audio_files.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// [LocalAudioFiles] backed by `dart:io` and `audio_metadata_reader`.
final class DartIoLocalAudioFiles implements LocalAudioFiles {
  /// Creates the adapter.
  const new();

  /// Extensions the scanner accepts.
  static const supportedExtensions = {'.mp3', '.flac', '.ogg', '.opus', '.m4a'};

  /// Files read per isolate run, balancing progress updates with spawn cost.
  static const _readBatchSize = 50;

  @override
  Future<List<String>> listAudioFiles(String folderPath) async {
    final folder = Directory(folderPath);
    if (!folder.existsSync()) {
      throw FileSystemException('Music folder not found', folderPath);
    }

    final files = <String>[];
    await for (final entity in folder.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final extension = p.extension(entity.path).toLowerCase();
      if (supportedExtensions.contains(extension)) files.add(entity.path);
    }
    files.sort();
    return files;
  }

  @override
  Future<List<LocalAudioTags>> readTags(List<String> paths) async {
    final tags = <LocalAudioTags>[];
    for (var start = 0; start < paths.length; start += _readBatchSize) {
      final end = (start + _readBatchSize).clamp(0, paths.length);
      tags.addAll(
        await Isolate.run(() => _readTagsInIsolate(paths.sublist(start, end))),
      );
    }
    return tags;
  }
}

List<LocalAudioTags> _readTagsInIsolate(List<String> paths) {
  // Folder fallbacks are read once per folder instead of once per track.
  final folderCovers = <String, Uint8List?>{};
  return [for (final path in paths) _readTags(path, folderCovers)];
}

LocalAudioTags _readTags(String path, Map<String, Uint8List?> folderCovers) {
  final format = p.extension(path).replaceFirst('.', '').toUpperCase();
  try {
    // Covers are the reason to read tags; the reader skips images by default.
    final metadata = readMetadata(File(path), getImage: true);
    final title = metadata.title?.trim();
    final cover =
        embeddedCover(metadata.pictures) ??
        folderCoverBytes(path, cache: folderCovers);
    return LocalAudioTags(
      path: path,
      title: title == null || title.isEmpty
          ? p.basenameWithoutExtension(path)
          : title,
      artist: _clean(metadata.artist),
      album: _clean(metadata.album),
      trackNumber: metadata.trackNumber,
      durationMs: metadata.duration?.inMilliseconds,
      sampleRateHz: metadata.sampleRate,
      // The reader reports bits per second across formats.
      bitrateKbps: metadata.bitrate == null
          ? null
          : (metadata.bitrate! / 1000).round(),
      format: format.isEmpty ? null : format,
      artworkRef: _hash(cover),
      lyrics: _clean(metadata.lyrics),
    );
  } on Exception {
    // Damaged files stay in the library under their file name.
    return LocalAudioTags(
      path: path,
      title: p.basenameWithoutExtension(path),
      format: format.isEmpty ? null : format,
      artworkRef: _hash(folderCoverBytes(path, cache: folderCovers)),
    );
  }
}

String? _hash(Uint8List? cover) {
  return cover == null ? null : sha256.convert(cover).toString();
}

String? _clean(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

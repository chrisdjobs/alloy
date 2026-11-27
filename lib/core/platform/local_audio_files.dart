/// Tags read from one local audio file.
///
/// A plain data carrier for the layer that reads files; the library feature
/// maps it to `Track` without knowing how the file was accessed.
class LocalAudioTags {
  /// Creates tags for the file at [path].
  const new({
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.trackNumber,
    this.durationMs,
    this.sampleRateHz,
    this.bitrateKbps,
    this.format,
    this.artworkRef,
    this.lyrics,
  });

  /// Absolute path of the audio file.
  final String path;

  /// Track title; falls back to the file name when the tags are empty.
  final String title;

  /// Main artist from the tags.
  final String? artist;

  /// Album from the tags.
  final String? album;

  /// Track order inside the album.
  final int? trackNumber;

  /// Track length in milliseconds.
  final int? durationMs;

  /// Sample rate in hertz.
  final int? sampleRateHz;

  /// Average bitrate in kilobits per second.
  final int? bitrateKbps;

  /// Container format such as `MP3` or `FLAC`.
  final String? format;

  /// SHA-256 of the embedded or folder cover, when the file has one.
  ///
  /// The hash is the opaque artwork reference stored on the track; it lets all
  /// tracks of one album share a single cached image.
  final String? artworkRef;

  /// Lyrics embedded in the tags, plain text or LRC.
  ///
  /// Read on demand by the player; the track model never carries the whole
  /// text, so lists do not load it for every row.
  final String? lyrics;
}

/// Reads tags from local audio files.
///
/// Implementations run off the UI thread; the library feature never touches
/// the file system directly.
abstract interface class LocalAudioFiles {
  /// Lists supported audio files under [folderPath], recursively.
  Future<List<String>> listAudioFiles(String folderPath);

  /// Reads tags for [paths] in one off-thread pass.
  ///
  /// Unreadable files still produce an entry with a file-name title so a scan
  /// never silently drops them.
  Future<List<LocalAudioTags>> readTags(List<String> paths);
}

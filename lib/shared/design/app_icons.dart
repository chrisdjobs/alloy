import 'package:material_ui/material_ui.dart';

/// Single swap point for functional icons.
abstract final class AppIcons {
  /// Library destination (inactive).
  static const IconData library = Icons.library_music_outlined;

  /// Library destination (active).
  static const IconData libraryActive = Icons.library_music;

  /// Settings destination (inactive).
  static const IconData settings = Icons.settings_outlined;

  /// Settings destination (active).
  static const IconData settingsActive = Icons.settings_rounded;

  /// Playback: play.
  static const IconData play = Icons.play_arrow_rounded;

  /// Playback: pause.
  static const IconData pause = Icons.pause_rounded;

  /// Playback: next track.
  static const IconData next = Icons.skip_next_rounded;

  /// Playback: previous track.
  static const IconData previous = Icons.skip_previous_rounded;

  /// Folder picker.
  static const IconData folder = Icons.folder_open_rounded;

  /// Generic track.
  static const IconData track = Icons.music_note_rounded;

  /// Error state.
  static const IconData error = Icons.error_outline_rounded;

  /// Shuffle playback.
  static const IconData shuffle = Icons.shuffle_rounded;

  /// Rescan the library.
  static const IconData refresh = Icons.refresh_rounded;

  /// Collapse the now-playing screen.
  static const IconData collapse = Icons.keyboard_arrow_down_rounded;

  /// Repeat the queue.
  static const IconData repeat = Icons.repeat_rounded;

  /// Repeat the current track.
  static const IconData repeatOne = Icons.repeat_one_rounded;

  /// Stop playback.
  static const IconData stop = Icons.stop_rounded;

  /// Track row overflow menu.
  static const IconData more = Icons.more_vert_rounded;
}

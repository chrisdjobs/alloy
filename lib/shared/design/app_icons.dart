import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

/// Functional icons resolved for one icon pack.
///
/// Widgets read the active set through `context.icons` (see
/// `shared/design/visual_theme.dart`), so switching packs never touches them.
final class AppIconSet {
  /// Creates a set; every glyph the UI draws must be provided.
  const new({
    required this.library,
    required this.settings,
    required this.home,
    required this.discover,
    required this.me,
    required this.play,
    required this.pause,
    required this.next,
    required this.previous,
    required this.folder,
    required this.track,
    required this.error,
    required this.shuffle,
    required this.refresh,
    required this.collapse,
    required this.repeat,
    required this.repeatOne,
    required this.stop,
    required this.more,
    required this.recent,
    required this.pass,
  });

  /// Library destination.
  final IconData library;

  /// Settings hub.
  final IconData settings;

  /// Home destination.
  final IconData home;

  /// Discover destination.
  final IconData discover;

  /// "Me" destination.
  final IconData me;

  /// Playback: play.
  final IconData play;

  /// Playback: pause.
  final IconData pause;

  /// Playback: next track.
  final IconData next;

  /// Playback: previous track.
  final IconData previous;

  /// Folder picker.
  final IconData folder;

  /// Generic track and the no-cover tile.
  final IconData track;

  /// Error state.
  final IconData error;

  /// Shuffle playback.
  final IconData shuffle;

  /// Rescan the library.
  final IconData refresh;

  /// Collapse the now-playing screen.
  final IconData collapse;

  /// Repeat the queue.
  final IconData repeat;

  /// Repeat the current track.
  final IconData repeatOne;

  /// Stop playback.
  final IconData stop;

  /// Overflow menu.
  final IconData more;

  /// Recently added shortcut.
  final IconData recent;

  /// Passes the current discovery card.
  final IconData pass;
}

/// Single swap point for functional icons.
///
/// The static glyphs are the Lucide default, so existing call sites keep their
/// `const` widgets. Prefer `context.icons` in new code so the user's pack wins.
abstract final class AppIcons {
  /// Library destination (Lucide).
  static const IconData library = LucideIcons.library;

  /// Settings destination (Lucide).
  static const IconData settings = LucideIcons.settings;

  /// Home destination (Lucide).
  static const IconData home = LucideIcons.house;

  /// Discover destination (Lucide).
  static const IconData discover = LucideIcons.compass;

  /// "Me" destination (Lucide).
  static const IconData me = LucideIcons.user;

  /// Playback: play (Lucide).
  static const IconData play = LucideIcons.play;

  /// Playback: pause (Lucide).
  static const IconData pause = LucideIcons.pause;

  /// Playback: next track (Lucide).
  static const IconData next = LucideIcons.skipForward;

  /// Playback: previous track (Lucide).
  static const IconData previous = LucideIcons.skipBack;

  /// Folder picker (Lucide).
  static const IconData folder = LucideIcons.folder;

  /// Generic track (Lucide).
  static const IconData track = LucideIcons.music;

  /// Error state (Lucide).
  static const IconData error = LucideIcons.circleAlert;

  /// Shuffle playback (Lucide).
  static const IconData shuffle = LucideIcons.shuffle;

  /// Rescan the library (Lucide).
  static const IconData refresh = LucideIcons.refreshCw;

  /// Collapse the now-playing screen (Lucide).
  static const IconData collapse = LucideIcons.chevronDown;

  /// Repeat the queue (Lucide).
  static const IconData repeat = LucideIcons.repeat;

  /// Repeat the current track (Lucide).
  static const IconData repeatOne = LucideIcons.repeat1;

  /// Stop playback (Lucide).
  static const IconData stop = LucideIcons.square;

  /// Overflow menu (Lucide).
  static const IconData more = LucideIcons.ellipsisVertical;

  /// Recently added shortcut (Lucide).
  static const IconData recent = LucideIcons.clock;

  /// Passes the current discovery card (Lucide).
  static const IconData pass = LucideIcons.x;

  /// Lucide outline pack, the default.
  static const AppIconSet lucide = AppIconSet(
    library: AppIcons.library,
    settings: AppIcons.settings,
    home: AppIcons.home,
    discover: AppIcons.discover,
    me: AppIcons.me,
    play: AppIcons.play,
    pause: AppIcons.pause,
    next: AppIcons.next,
    previous: AppIcons.previous,
    folder: AppIcons.folder,
    track: AppIcons.track,
    error: AppIcons.error,
    shuffle: AppIcons.shuffle,
    refresh: AppIcons.refresh,
    collapse: AppIcons.collapse,
    repeat: AppIcons.repeat,
    repeatOne: AppIcons.repeatOne,
    stop: AppIcons.stop,
    more: AppIcons.more,
    recent: AppIcons.recent,
    pass: AppIcons.pass,
  );

  /// Material pack.
  static const AppIconSet material = AppIconSet(
    library: Icons.library_music_outlined,
    settings: Icons.settings_outlined,
    home: Icons.home_outlined,
    discover: Icons.explore_outlined,
    me: Icons.person_outline_rounded,
    play: Icons.play_arrow_rounded,
    pause: Icons.pause_rounded,
    next: Icons.skip_next_rounded,
    previous: Icons.skip_previous_rounded,
    folder: Icons.folder_open_rounded,
    track: Icons.music_note_rounded,
    error: Icons.error_outline_rounded,
    shuffle: Icons.shuffle_rounded,
    refresh: Icons.refresh_rounded,
    collapse: Icons.keyboard_arrow_down_rounded,
    repeat: Icons.repeat_rounded,
    repeatOne: Icons.repeat_one_rounded,
    stop: Icons.stop_rounded,
    more: Icons.more_vert_rounded,
    recent: Icons.schedule_rounded,
    pass: Icons.close_rounded,
  );
}

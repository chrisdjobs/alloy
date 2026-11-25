// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Alloy';

  @override
  String get homeTitle => 'Home';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryTracks => 'Tracks';

  @override
  String get libraryPlaylists => 'Playlists';

  @override
  String get libraryArtists => 'Artists';

  @override
  String get libraryAlbums => 'Albums';

  @override
  String get libraryOptions => 'Library options';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortTitleAscending => 'A-Z';

  @override
  String get sortTitleDescending => 'Z-A';

  @override
  String get sortOldestAdded => 'Oldest added';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortDuration => 'Duration';

  @override
  String get showDuration => 'Show duration';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get generalTitle => 'General';

  @override
  String get accentColor => 'Accent color';

  @override
  String get iconsSection => 'Icons';

  @override
  String appearanceSummary(String iconPack) {
    return 'Accent color · $iconPack';
  }

  @override
  String get iconPackLucide => 'Lucide';

  @override
  String get iconPackMaterial => 'Material';

  @override
  String get languageTitle => 'Language';

  @override
  String get systemLanguage => 'System language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get musicAndStorageTitle => 'Music and storage';

  @override
  String get musicFolders => 'Music folders';

  @override
  String get chooseFolderHint => 'Where Alloy looks for your music';

  @override
  String get rescanLibraryHint => 'Look for new files in the same folder';

  @override
  String trackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: 'No tracks',
    );
    return '$_temp0';
  }

  @override
  String albumCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums',
      one: '1 album',
      zero: 'No albums',
    );
    return '$_temp0';
  }

  @override
  String libraryStats(String tracks, String albums) {
    return '$tracks · $albums';
  }

  @override
  String musicFoldersSummary(String tracks) {
    return 'Folders · $tracks';
  }

  @override
  String get meTitle => 'Me';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get chooseFolder => 'Choose folder';

  @override
  String get scanning => 'Scanning…';

  @override
  String get noTracksFound => 'No tracks found';

  @override
  String get error => 'Error';

  @override
  String get next => 'Next';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get previous => 'Previous';

  @override
  String get stopPlayback => 'Stop playback';

  @override
  String get moreOptions => 'More options';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatOne => 'Repeat one';

  @override
  String get repeatOff => 'Repeat off';

  @override
  String get playNext => 'Play next';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String queuePosition(int position, int total) {
    return '$position of $total';
  }

  @override
  String audioQuality(String sampleRate, String bitrate, String format) {
    return '$sampleRate kHz · $bitrate kbps · $format';
  }

  @override
  String get shuffleAll => 'Shuffle all';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesComingSoon => 'Your favorite tracks will live here';

  @override
  String get rescanLibrary => 'Rescan library';

  @override
  String get recentlyAdded => 'Recently added';

  @override
  String get discoverPass => 'Pass';

  @override
  String get discoverReshuffle => 'Reshuffle';

  @override
  String ofDuration(String duration) {
    return 'of $duration';
  }

  @override
  String get mixesForYou => 'Mixes for you';

  @override
  String get mixOnRotationTitle => 'Your rotation';

  @override
  String get mixOnRotationSubtitle => 'What you keep coming back to';

  @override
  String get mixDeepCutsTitle => 'Deep cuts';

  @override
  String get mixDeepCutsSubtitle => 'Hidden gems from your library';

  @override
  String get mostPlayed => 'Most played';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String playCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plays',
      one: '1 play',
      zero: 'No plays',
    );
    return '$_temp0';
  }

  @override
  String get activity => 'Activity';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalLength => 'Length';

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }
}

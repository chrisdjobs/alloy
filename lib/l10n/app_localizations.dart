// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Alloy'**
  String get appTitle;

  /// Top-level home destination and screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Top-level discover destination and screen title
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// Top-level library destination and screen title
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Library tab that lists every track
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get libraryTracks;

  /// Library tab for playlists; not implemented yet
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get libraryPlaylists;

  /// Library tab for artists; not implemented yet
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get libraryArtists;

  /// Library tab for albums; not implemented yet
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get libraryAlbums;

  /// Opens the sheet with the library sort and row options
  ///
  /// In en, this message translates to:
  /// **'Library options'**
  String get libraryOptions;

  /// Tooltip of the library search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Hint of the library search field
  ///
  /// In en, this message translates to:
  /// **'Search by title or artist'**
  String get searchHint;

  /// Empty state of the library search when nothing matches
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noSearchResults;

  /// Section label above the sort chips of the library sheet
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// Sort chip: track title, A to Z
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortTitleAscending;

  /// Sort chip: track title, Z to A
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortTitleDescending;

  /// Sort chip: oldest dateAdded first
  ///
  /// In en, this message translates to:
  /// **'Oldest added'**
  String get sortOldestAdded;

  /// Sort chip: album name
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get sortAlbum;

  /// Sort chip: artist name
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// Sort chip: track length
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sortDuration;

  /// Toggle that shows the track length in every library row
  ///
  /// In en, this message translates to:
  /// **'Show duration'**
  String get showDuration;

  /// Settings screen with the look of the app
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Settings screen with the accent color and the icon pack
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalTitle;

  /// Section of the general settings with the accent swatches
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// Section of the general settings with the icon pack choices
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get iconsSection;

  /// Section of the general settings that picks the launcher icon
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get appIconSection;

  /// Note under the app icon picker about when the launcher refreshes
  ///
  /// In en, this message translates to:
  /// **'The new icon is applied when you leave Alloy.'**
  String get appIconHint;

  /// Name of the default four-bar app icon
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get iconNameDefault;

  /// Name of the cpunk gradient app icon
  ///
  /// In en, this message translates to:
  /// **'cpunk'**
  String get iconNameCpunk;

  /// Toggle that makes the accent follow the app icon's dominant color
  ///
  /// In en, this message translates to:
  /// **'Icon Color'**
  String get accentFromIcon;

  /// Explanation under the colour-of-your-icon toggle
  ///
  /// In en, this message translates to:
  /// **'The accent takes your app icon\'s colour and changes with it.'**
  String get accentFromIconSubtitle;

  /// Subtitle of the appearance row; names the active icon pack
  ///
  /// In en, this message translates to:
  /// **'Accent color · {iconPack}'**
  String appearanceSummary(String iconPack);

  /// Name of the Lucide icon pack
  ///
  /// In en, this message translates to:
  /// **'Lucide'**
  String get iconPackLucide;

  /// Name of the Material icon pack
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get iconPackMaterial;

  /// Settings screen with the language override
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Language option that follows the phone's locale
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Spanish language option, written in Spanish
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Settings screen with the library folder and its size
  ///
  /// In en, this message translates to:
  /// **'Music and storage'**
  String get musicAndStorageTitle;

  /// Section of the storage settings that lists the library folder
  ///
  /// In en, this message translates to:
  /// **'Music folders'**
  String get musicFolders;

  /// Subtitle of the folder picker row in the storage settings
  ///
  /// In en, this message translates to:
  /// **'Where Alloy looks for your music'**
  String get chooseFolderHint;

  /// Subtitle of the rescan row in the storage settings
  ///
  /// In en, this message translates to:
  /// **'Look for new files in the same folder'**
  String get rescanLibraryHint;

  /// Number of tracks in the library
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tracks} =1{1 track} other{{count} tracks}}'**
  String trackCount(int count);

  /// Number of albums in the library
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No albums} =1{1 album} other{{count} albums}}'**
  String albumCount(int count);

  /// Line under the app name with the size of the library
  ///
  /// In en, this message translates to:
  /// **'{tracks} · {albums}'**
  String libraryStats(String tracks, String albums);

  /// Subtitle of the music and storage row
  ///
  /// In en, this message translates to:
  /// **'Folders · {tracks}'**
  String musicFoldersSummary(String tracks);

  /// Label of the settings hub destination in the navigation bar
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// Top-level settings destination and screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Caption of a destination that is designed but not built yet
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Playback action
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Playback action
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Action that opens the folder picker
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get chooseFolder;

  /// Library scan in progress
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get scanning;

  /// Empty library state
  ///
  /// In en, this message translates to:
  /// **'No tracks found'**
  String get noTracksFound;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Playback action that skips to the next track
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Action that tries the failed operation again
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Closes the full-screen player
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Now-playing action that shares the current track
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Now-playing action that opens the playback queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// Empty state of the playback queue sheet
  ///
  /// In en, this message translates to:
  /// **'The queue is empty'**
  String get queueEmpty;

  /// Playback action that goes back to the previous track
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Overflow action that stops playback and clears the player
  ///
  /// In en, this message translates to:
  /// **'Stop playback'**
  String get stopPlayback;

  /// Opens the menu with secondary player actions
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// Title of the full-screen player
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// Tooltip for the shuffle toggle
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// Tooltip for the repeat mode toggle
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// Repeat mode that loops the current track
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get repeatOne;

  /// Repeat mode that stops after the queue
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get repeatOff;

  /// Queue action that inserts the track after the current one
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// Queue action that appends the track to the end
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// Position of the current track inside the queue
  ///
  /// In en, this message translates to:
  /// **'{position} of {total}'**
  String queuePosition(int position, int total);

  /// Technical line under the seek bar of the now-playing screen
  ///
  /// In en, this message translates to:
  /// **'{sampleRate} kHz · {bitrate} kbps · {format}'**
  String audioQuality(String sampleRate, String bitrate, String format);

  /// Library action that plays the whole library in random order
  ///
  /// In en, this message translates to:
  /// **'Shuffle all'**
  String get shuffleAll;

  /// Home shortcut and screen title for the favorited tracks
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Caption of the favorites placeholder screen
  ///
  /// In en, this message translates to:
  /// **'Your favorite tracks will live here'**
  String get favoritesComingSoon;

  /// Tooltip for the action that scans the last folder again
  ///
  /// In en, this message translates to:
  /// **'Rescan library'**
  String get rescanLibrary;

  /// Home section and shortcut for the newest tracks
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get recentlyAdded;

  /// Discover action that skips the current card
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get discoverPass;

  /// Discover action that deals a new deck of tracks
  ///
  /// In en, this message translates to:
  /// **'Reshuffle'**
  String get discoverReshuffle;

  /// Total length under the discover waveform
  ///
  /// In en, this message translates to:
  /// **'of {duration}'**
  String ofDuration(String duration);

  /// Home section with generated track mixes
  ///
  /// In en, this message translates to:
  /// **'Mixes for you'**
  String get mixesForYou;

  /// Name of the mix built from the tracks played most right now
  ///
  /// In en, this message translates to:
  /// **'Your rotation'**
  String get mixOnRotationTitle;

  /// Description of the rotation mix
  ///
  /// In en, this message translates to:
  /// **'What you keep coming back to'**
  String get mixOnRotationSubtitle;

  /// Name of the mix built from less played library tracks
  ///
  /// In en, this message translates to:
  /// **'Deep cuts'**
  String get mixDeepCutsTitle;

  /// Description of the deep cuts mix
  ///
  /// In en, this message translates to:
  /// **'Hidden gems from your library'**
  String get mixDeepCutsSubtitle;

  /// Home section that ranks the tracks with the most plays
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get mostPlayed;

  /// Statistics window of the last seven days
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Statistics window of the last thirty days
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Number of plays of a track inside the selected window
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No plays} =1{1 play} other{{count} plays}}'**
  String playCount(int count);

  /// Expands the most played ranking to the whole list
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Home section with the daily plays bar chart
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Home section with the library totals
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Activity label for the listening time of today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Activity label for the listening time of the last seven days
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// Activity label for the consecutive listening days
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Number of consecutive listening days
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{0 days} =1{1 day} other{{days} days}}'**
  String dayCount(int days);

  /// Listening time with hours and minutes, such as 1 h 07 min
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, String minutes);

  /// Label of the total listening length in the statistics card
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get totalLength;

  /// Listening length with minutes, used below one hour
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// Listening length in whole hours, such as 26 h
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// Lyrics of the current track: statistics row and player action
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// Tracks with time-synced lyrics
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get lyricsSynced;

  /// Tracks with plain-text lyrics
  ///
  /// In en, this message translates to:
  /// **'Text only'**
  String get lyricsTextOnly;

  /// Tracks without lyrics
  ///
  /// In en, this message translates to:
  /// **'No lyrics'**
  String get lyricsNone;

  /// Count and share of one lyrics kind, such as 27 · 6%
  ///
  /// In en, this message translates to:
  /// **'{count} · {percent}%'**
  String lyricsStat(int count, int percent);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

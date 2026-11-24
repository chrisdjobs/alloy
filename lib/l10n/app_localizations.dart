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
  /// **'Bars'**
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

  /// Tooltip for the action that scans the last folder again
  ///
  /// In en, this message translates to:
  /// **'Rescan library'**
  String get rescanLibrary;
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

// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bars';

  @override
  String get libraryTitle => 'Library';

  @override
  String get settingsTitle => 'Settings';

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
}

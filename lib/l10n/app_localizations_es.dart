// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bars';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get chooseFolder => 'Elegir carpeta';

  @override
  String get scanning => 'Escaneando…';

  @override
  String get noTracksFound => 'No se encontraron pistas';

  @override
  String get error => 'Error';

  @override
  String get next => 'Siguiente';

  @override
  String get retry => 'Reintentar';

  @override
  String get nowPlaying => 'Reproduciendo ahora';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get repeat => 'Repetir';

  @override
  String get repeatOne => 'Repetir una';

  @override
  String get repeatOff => 'Repetir desactivado';

  @override
  String get playNext => 'Reproducir a continuación';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String queuePosition(int position, int total) {
    return '$position de $total';
  }

  @override
  String audioQuality(String sampleRate, String bitrate, String format) {
    return '$sampleRate kHz · $bitrate kbps · $format';
  }

  @override
  String get shuffleAll => 'Aleatorio';

  @override
  String get rescanLibrary => 'Volver a escanear la biblioteca';
}

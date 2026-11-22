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
}

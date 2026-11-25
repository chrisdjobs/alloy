// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Alloy';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get discoverTitle => 'Descubrir';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryTracks => 'Pistas';

  @override
  String get libraryPlaylists => 'Listas';

  @override
  String get libraryArtists => 'Artistas';

  @override
  String get libraryAlbums => 'Álbumes';

  @override
  String get libraryOptions => 'Opciones de la biblioteca';

  @override
  String get sortBy => 'Ordenar';

  @override
  String get sortTitleAscending => 'A-Z';

  @override
  String get sortTitleDescending => 'Z-A';

  @override
  String get sortOldestAdded => 'Más antiguos';

  @override
  String get sortAlbum => 'Álbum';

  @override
  String get sortArtist => 'Artista';

  @override
  String get sortDuration => 'Duración';

  @override
  String get showDuration => 'Mostrar duración';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get generalTitle => 'General';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get iconsSection => 'Iconos';

  @override
  String appearanceSummary(String iconPack) {
    return 'Color de acento · $iconPack';
  }

  @override
  String get iconPackLucide => 'Lucide';

  @override
  String get iconPackMaterial => 'Material';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get musicAndStorageTitle => 'Música y almacenamiento';

  @override
  String get musicFolders => 'Carpetas de música';

  @override
  String get chooseFolderHint => 'Dónde busca Alloy tu música';

  @override
  String get rescanLibraryHint => 'Busca archivos nuevos en la misma carpeta';

  @override
  String trackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
      zero: 'Sin pistas',
    );
    return '$_temp0';
  }

  @override
  String albumCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count álbumes',
      one: '1 álbum',
      zero: 'Sin álbumes',
    );
    return '$_temp0';
  }

  @override
  String libraryStats(String tracks, String albums) {
    return '$tracks · $albums';
  }

  @override
  String musicFoldersSummary(String tracks) {
    return 'Carpetas · $tracks';
  }

  @override
  String get meTitle => 'Yo';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get comingSoon => 'Próximamente';

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
  String get close => 'Cerrar';

  @override
  String get previous => 'Anterior';

  @override
  String get stopPlayback => 'Detener la reproducción';

  @override
  String get moreOptions => 'Más opciones';

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
  String get favorites => 'Favoritos';

  @override
  String get favoritesComingSoon => 'Tus pistas favoritas vivirán aquí';

  @override
  String get rescanLibrary => 'Volver a escanear la biblioteca';

  @override
  String get recentlyAdded => 'Añadidos recientes';

  @override
  String get discoverPass => 'Pasar';

  @override
  String get discoverReshuffle => 'Reordenar';

  @override
  String ofDuration(String duration) {
    return 'de $duration';
  }

  @override
  String get mixesForYou => 'Mezclas para ti';

  @override
  String get mixOnRotationTitle => 'Tu rotación';

  @override
  String get mixOnRotationSubtitle => 'Lo que más escuchas ahora';

  @override
  String get mixDeepCutsTitle => 'Joyas ocultas';

  @override
  String get mixDeepCutsSubtitle => 'Tesoros escondidos en tu biblioteca';

  @override
  String get mostPlayed => 'Más escuchadas';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String playCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reproducciones',
      one: '1 reproducción',
      zero: 'Sin reproducciones',
    );
    return '$_temp0';
  }

  @override
  String get activity => 'Actividad';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get totalLength => 'Duración';

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }
}

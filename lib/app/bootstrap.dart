import 'dart:async';

import 'package:alloy/app/router.dart';
import 'package:alloy/app/theme.dart';
import 'package:alloy/core/artwork/artwork_providers.dart';
import 'package:alloy/core/logger.dart';
import 'package:alloy/core/platform/app_icon_switcher.dart';
import 'package:alloy/core/platform/audio_permission.dart';
import 'package:alloy/core/platform/dart_io_artwork_store.dart';
import 'package:alloy/core/platform/dart_io_folder_store.dart';
import 'package:alloy/core/platform/dart_io_local_audio_files.dart';
import 'package:alloy/core/platform/dart_io_local_cover_reader.dart';
import 'package:alloy/core/platform/dart_io_platform_info.dart';
import 'package:alloy/core/platform/folder_picker.dart';
import 'package:alloy/core/platform/permission_handler_audio_permission.dart';
import 'package:alloy/core/platform/platform_info.dart';
import 'package:alloy/features/library/data/artwork_cache.dart';
import 'package:alloy/features/library/data/artwork_repository_impl.dart';
import 'package:alloy/features/library/data/database/app_database.dart';
import 'package:alloy/features/library/data/library_repository_impl.dart';
import 'package:alloy/features/library/data/local_artwork_source.dart';
import 'package:alloy/features/library/data/local_lyrics_provider.dart';
import 'package:alloy/features/library/data/local_music_source.dart';
import 'package:alloy/features/library/domain/lyrics_provider_ref.dart';
import 'package:alloy/features/library/presentation/library_notifier.dart';
import 'package:alloy/features/player/data/android_playback_engine.dart';
import 'package:alloy/features/player/data/audio_handler.dart';
import 'package:alloy/features/player/data/audio_service_playback_engine.dart';
import 'package:alloy/features/player/data/linux_playback_engine.dart';
import 'package:alloy/features/player/domain/playback_engine.dart';
import 'package:alloy/features/player/presentation/player_notifier.dart';
import 'package:alloy/features/settings/data/database/settings_database.dart';
import 'package:alloy/features/settings/data/drift_settings_repository.dart';
import 'package:alloy/features/settings/domain/app_settings.dart';
import 'package:alloy/features/settings/presentation/settings_notifier.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/gradient_presets.dart';
import 'package:alloy/shared/design/gradient_presets_provider.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:material_ui/material_ui.dart';

/// Starts the app and installs the platform-specific provider overrides.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Registers media_kit on Linux and Windows; a no-op elsewhere.
  JustAudioMediaKit.ensureInitialized();

  const platform = DartIoPlatformInfo();
  final appIconSwitcher = platform.isAndroid || platform.isLinux
      ? const MethodChannelAppIconSwitcher()
      : const NoopAppIconSwitcher();
  final database = AppDatabase();
  final source = LocalMusicSource(
    database: database,
    files: const DartIoLocalAudioFiles(),
  );
  final libraryRepository = LibraryRepositoryImpl(
    source: source,
    folderPicker: const FilePickerFolderPicker(),
    permission: platform.isAndroid
        ? const PermissionHandlerAudioPermission()
        : const GrantedAudioPermission(),
    folderStore: const DartIoFolderStore(),
  );
  final artworkRepository = ArtworkRepositoryImpl(
    cache: ArtworkCache(store: DartIoArtworkStore()),
    loadBytes: LocalArtworkSource(
      database: database,
      reader: const DartIoLocalCoverReader(),
    ).coverBytes,
  );

  final engine = await _createEngine(platform, resolveUri: source.resolveUri);

  final settingsDatabase = SettingsDatabase();
  final settingsRepository = DriftSettingsRepository(
    database: settingsDatabase,
  );
  try {
    await settingsRepository.load();
  } on Exception catch (error, stackTrace) {
    Logger.error(
      'Could not load the settings, using defaults',
      error: error,
      stackTrace: stackTrace,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        playbackEngineProvider.overrideWithValue(engine),
        artworkRepositoryProvider.overrideWithValue(artworkRepository),
        libraryRepositoryProvider.overrideWith((ref) {
          ref.onDispose(() {
            unawaited(libraryRepository.dispose());
            unawaited(database.close());
          });
          return libraryRepository;
        }),
        lyricsProvider.overrideWith((ref) {
          ref.onDispose(() {});
          return LocalLyricsProvider(database: database);
        }),
        settingsRepositoryProvider.overrideWith((ref) {
          ref.onDispose(() {
            unawaited(settingsRepository.dispose());
            unawaited(settingsDatabase.close());
          });
          return settingsRepository;
        }),
        appIconSwitcherProvider.overrideWithValue(appIconSwitcher),
        activeGradientPresetProvider.overrideWith((ref) {
          final settings = ref.watch(settingsProvider);
          return AppGradientPresets.byId(settings.appIconId) ??
              AppGradientPresets.active;
        }),
        routerProvider.overrideWithValue(
          createAppRouter(
            initialLocation: _initialLocation(
              settingsRepository.current.startTab,
            ),
          ),
        ),
      ],
      child: const AlloyApp(),
    ),
  );

  if (platform.isAndroid || platform.isLinux) {
    unawaited(
      _syncAppIcon(appIconSwitcher, settingsRepository.current.appIconId),
    );
  }
}

/// Applies the saved launcher icon after a restore or a fresh install.
Future<void> _syncAppIcon(AppIconSwitcher switcher, String id) async {
  final applied = await switcher.setIcon(id);
  if (!applied) {
    Logger.warning('Could not apply the saved app icon $id');
  }
}

/// Route the app opens on for [tab].
String _initialLocation(AppTab tab) {
  return switch (tab) {
    AppTab.home => '/home',
    AppTab.discover => '/discover',
    AppTab.library => '/library',
    AppTab.me => '/settings',
  };
}

/// Builds the playback engine that matches [platform].
///
/// If the platform media session cannot start, playback still works without
/// notification controls instead of failing the whole app.
Future<PlaybackEngine> _createEngine(
  PlatformInfo platform, {
  required TrackUriResolver resolveUri,
}) async {
  try {
    return switch (platform.platform) {
      AppPlatform.android => await AndroidPlaybackEngine.connect(
        resolveUri: resolveUri,
      ),
      AppPlatform.linux => await LinuxPlaybackEngine.connect(
        resolveUri: resolveUri,
      ),
      // Other platforms are not tested yet; start without a media session
      // instead of blocking them.
      AppPlatform.other => _sessionLessEngine(resolveUri),
    };
  } on Exception catch (error, stackTrace) {
    Logger.error(
      'Media session unavailable, continuing without it',
      error: error,
      stackTrace: stackTrace,
    );
    return _sessionLessEngine(resolveUri);
  }
}

PlaybackEngine _sessionLessEngine(TrackUriResolver resolveUri) {
  return AudioServicePlaybackEngine(
    handler: AlloyAudioHandler(resolveUri: resolveUri),
  );
}

/// Root widget: theme, router and localization configuration.
class AlloyApp extends ConsumerWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final preset = ref.watch(activeGradientPresetProvider);
    final accentArgb = settings.accentArgb;
    final localeCode = settings.localeCode;
    final accent = settings.accentFromIcon
        ? preset.accent
        : (accentArgb == null ? AppColors.accent : Color(accentArgb));

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.dark(
        accent: accent,
        icons: _iconSet(settings.iconPack),
        base: preset.base,
      ),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      locale: localeCode == null ? null : Locale(localeCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Glyph set of [pack].
AppIconSet _iconSet(AppIconPack pack) {
  return switch (pack) {
    AppIconPack.lucide => AppIcons.lucide,
    AppIconPack.material => AppIcons.material,
  };
}

import 'package:bars/app/router.dart';
import 'package:bars/app/theme.dart';
import 'package:bars/core/logger.dart';
import 'package:bars/core/platform/dart_io_platform_info.dart';
import 'package:bars/core/platform/platform_info.dart';
import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/player/data/android_playback_engine.dart';
import 'package:bars/features/player/data/audio_handler.dart';
import 'package:bars/features/player/data/audio_service_playback_engine.dart';
import 'package:bars/features/player/data/linux_playback_engine.dart';
import 'package:bars/features/player/domain/playback_engine.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:material_ui/material_ui.dart';

/// Starts the app and installs the platform-specific provider overrides.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Registers media_kit on Linux and Windows; a no-op elsewhere.
  JustAudioMediaKit.ensureInitialized();

  final engine = await _createEngine(const DartIoPlatformInfo());

  runApp(
    ProviderScope(
      overrides: [playbackEngineProvider.overrideWithValue(engine)],
      child: const BarsApp(),
    ),
  );
}

/// Builds the playback engine that matches [platform].
///
/// If the platform media session cannot start, playback still works without
/// notification controls instead of failing the whole app.
Future<PlaybackEngine> _createEngine(PlatformInfo platform) async {
  // Phase 4 replaces this with MusicSource.resolveUri.
  Uri resolveUri(Track track) => Uri.file(track.sourceItemId);

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
    handler: BarsAudioHandler(resolveUri: resolveUri),
  );
}

/// Root widget: theme, router and localization configuration.
class BarsApp extends ConsumerWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

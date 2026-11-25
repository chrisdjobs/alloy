import 'dart:async';

import 'package:alloy/app/branch_fade.dart';
import 'package:alloy/app/player_transition.dart';
import 'package:alloy/app/shell.dart';
import 'package:alloy/features/discover/presentation/discover_screen.dart';
import 'package:alloy/features/home/presentation/home_screen.dart';
import 'package:alloy/features/library/presentation/library_notifier.dart';
import 'package:alloy/features/library/presentation/library_screen.dart';
import 'package:alloy/features/player/presentation/now_playing_screen.dart';
import 'package:alloy/features/player/presentation/player_notifier.dart';
import 'package:alloy/features/settings/presentation/appearance_screen.dart';
import 'package:alloy/features/settings/presentation/general_screen.dart';
import 'package:alloy/features/settings/presentation/language_screen.dart';
import 'package:alloy/features/settings/presentation/music_storage_screen.dart';
import 'package:alloy/features/settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Builds the app router with one branch per top-level destination.
///
/// Branches follow `AppTab.values` order, so the shell can map a tab to its
/// branch index.
GoRouter createAppRouter({String initialLocation = '/library'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute(
        navigatorContainerBuilder: fadeBranchContainer,
        builder: (context, state, navigationShell) =>
            AdaptiveShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) => HomeScreen(
                    tracks: ref.watch(libraryProvider),
                    onPlay: (tracks, index) {
                      unawaited(
                        ref
                            .read(playerProvider.notifier)
                            .loadQueueAndPlay(tracks, index),
                      );
                    },
                    onShuffleAll: (tracks) {
                      unawaited(
                        ref.read(playerProvider.notifier).shuffleAll(tracks),
                      );
                    },
                    onChooseFolder: () {
                      unawaited(
                        ref.read(libraryProvider.notifier).scanFolder(),
                      );
                    },
                    onRetry: () => ref.invalidate(libraryProvider),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) => DiscoverScreen(
                    tracks: ref.watch(libraryProvider),
                    playback: ref.watch(playerProvider).value,
                    onPlay: (tracks, index) {
                      unawaited(
                        ref
                            .read(playerProvider.notifier)
                            .loadQueueAndPlay(tracks, index),
                      );
                    },
                    onTogglePlayPause: () {
                      unawaited(
                        ref.read(playerProvider.notifier).togglePlayPause(),
                      );
                    },
                    onSeek: (position) {
                      unawaited(
                        ref.read(playerProvider.notifier).seek(position),
                      );
                    },
                    onChooseFolder: () {
                      unawaited(
                        ref.read(libraryProvider.notifier).scanFolder(),
                      );
                    },
                    onRetry: () => ref.invalidate(libraryProvider),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) {
                    final currentTrackId = ref.watch(
                      playerProvider.select((state) => state.value?.track?.id),
                    );
                    final isPlaying = ref.watch(
                      playerProvider.select(
                        (state) => state.value?.playing ?? false,
                      ),
                    );
                    return LibraryScreen(
                      currentTrackId: currentTrackId,
                      isPlaying: isPlaying,
                      onPlay: (tracks, index) {
                        unawaited(
                          ref
                              .read(playerProvider.notifier)
                              .loadQueueAndPlay(tracks, index),
                        );
                      },
                      onShuffleAll: (tracks) {
                        unawaited(
                          ref.read(playerProvider.notifier).shuffleAll(tracks),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) =>
                      SettingsScreen(tracks: ref.watch(libraryProvider)),
                ),
                routes: [
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) => const AppearanceScreen(),
                    routes: [
                      GoRoute(
                        path: 'general',
                        builder: (context, state) => const GeneralScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'language',
                    builder: (context, state) => const LanguageScreen(),
                  ),
                  GoRoute(
                    path: 'storage',
                    builder: (context, state) => Consumer(
                      builder: (context, ref, _) => MusicStorageScreen(
                        tracks: ref.watch(libraryProvider),
                        onChooseFolder: () {
                          unawaited(
                            ref.read(libraryProvider.notifier).scanFolder(),
                          );
                        },
                        onRescan: () {
                          unawaited(
                            ref.read(libraryProvider.notifier).triggerScan(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Above the shell so the mini-player stays put underneath and both
      // covers can share one Hero.
      GoRoute(
        path: '/now-playing',
        pageBuilder: (context, state) =>
            playerPage(key: state.pageKey, child: const NowPlayingScreen()),
      ),
    ],
  );
}

/// Router instance for the app; kept as a provider like other services.
final routerProvider = Provider<GoRouter>((_) => createAppRouter());

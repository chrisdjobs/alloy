import 'dart:async';

import 'package:bars/app/shell.dart';
import 'package:bars/features/discover/presentation/discover_screen.dart';
import 'package:bars/features/home/presentation/home_screen.dart';
import 'package:bars/features/library/presentation/library_screen.dart';
import 'package:bars/features/player/presentation/now_playing_screen.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/features/settings/presentation/settings_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdaptiveShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) => LibraryScreen(
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
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Above the shell so the mini-player stays put underneath and both
      // covers can share one Hero.
      GoRoute(
        path: '/now-playing',
        builder: (context, state) => const NowPlayingScreen(),
      ),
    ],
  );
}

/// Router instance for the app; kept as a provider like other services.
final routerProvider = Provider<GoRouter>((_) => createAppRouter());

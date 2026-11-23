import 'dart:async';

import 'package:bars/app/shell.dart';
import 'package:bars/features/library/presentation/library_screen.dart';
import 'package:bars/features/player/presentation/player_notifier.dart';
import 'package:bars/features/settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Builds the app router with one branch per top-level destination.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/library',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdaptiveShell(navigationShell: navigationShell),
        branches: [
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
    ],
  );
}

/// Router instance for the app; kept as a provider like other services.
final routerProvider = Provider<GoRouter>((_) => createAppRouter());

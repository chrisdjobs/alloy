import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/library/presentation/library_notifier.dart';
import 'package:bars/features/library/presentation/track_tile.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/app_icons.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/widgets/tbd_placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Plays [tracks] starting at [index].
typedef PlayTracksCallback = void Function(List<Track> tracks, int index);

/// Plays [tracks] in random order.
typedef ShuffleTracksCallback = void Function(List<Track> tracks);

/// Library screen: track list with empty, loading, error and data states.
///
/// Playback callbacks are injected by the router so this feature never imports
/// the player feature's presentation layer.
class LibraryScreen extends ConsumerWidget {
  /// Creates the library screen.
  const new({required this.onPlay, required this.onShuffleAll, super.key});

  /// Opens a track from the list.
  final PlayTracksCallback onPlay;

  /// Starts the whole library in shuffle mode.
  final ShuffleTracksCallback onShuffleAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tracks = ref.watch(libraryProvider);
    final progress = ref.watch(scanProgressProvider).value;
    final scanning = progress != null && !progress.isComplete;
    final notifier = ref.read(libraryProvider.notifier);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.libraryTitle, style: AppTextStyles.headline),
                ),
                IconButton(
                  onPressed: () async {
                    await notifier.triggerScan();
                  },
                  tooltip: l10n.rescanLibrary,
                  icon: const Icon(AppIcons.refresh),
                ),
              ],
            ),
          ),
          if (scanning) const _ScanBanner(),
          Expanded(
            child: switch (tracks) {
              AsyncValue(hasError: true) => _ErrorState(
                onRetry: () => ref.invalidate(libraryProvider),
              ),
              AsyncValue(hasValue: true, :final value?) when value.isEmpty =>
                _EmptyState(
                  onChooseFolder: () async {
                    await notifier.scanFolder();
                  },
                ),
              AsyncValue(:final value?) => _TrackList(
                tracks: value,
                onPlay: onPlay,
                onShuffleAll: onShuffleAll,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _ScanBanner extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(scanProgressProvider).value;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              progress == null || progress.filesFound == 0
                  ? l10n.scanning
                  : '${l10n.scanning} ${progress.filesRead}/${progress.filesFound}',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackList extends StatelessWidget {
  const new({
    required this.tracks,
    required this.onPlay,
    required this.onShuffleAll,
  });

  final List<Track> tracks;
  final PlayTracksCallback onPlay;
  final ShuffleTracksCallback onShuffleAll;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: tracks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ShuffleAllRow(onTap: () => onShuffleAll(tracks));
        }
        final trackIndex = index - 1;
        return TrackTile(
          track: tracks[trackIndex],
          onTap: () => onPlay(tracks, trackIndex),
        );
      },
    );
  }
}

class _ShuffleAllRow extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(AppIcons.shuffle, color: accent, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(
                  l10n.shuffleAll,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const new({required this.onChooseFolder});

  final VoidCallback onChooseFolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TbdPlaceholder(width: 132, height: 132),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.noTracksFound, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onChooseFolder,
              icon: const Icon(AppIcons.folder),
              label: Text(l10n.chooseFolder),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.error, color: AppColors.error, size: 32),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.error, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(AppIcons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

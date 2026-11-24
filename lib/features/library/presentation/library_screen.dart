import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/library/domain/track_sort.dart';
import 'package:bars/features/library/presentation/library_notifier.dart';
import 'package:bars/features/library/presentation/library_options_sheet.dart';
import 'package:bars/features/library/presentation/library_view_options.dart';
import 'package:bars/features/library/presentation/track_tile.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:bars/shared/widgets/bars_page_header.dart';
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
  const new({
    required this.onPlay,
    required this.onShuffleAll,
    this.currentTrackId,
    this.isPlaying = false,
    super.key,
  });

  /// Opens a track from the list.
  final PlayTracksCallback onPlay;

  /// Starts the whole library in shuffle mode.
  final ShuffleTracksCallback onShuffleAll;

  /// Id of the track loaded in the player; its row marks itself.
  final String? currentTrackId;

  /// Whether the loaded track is playing.
  final bool isPlaying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tracks = ref.watch(libraryProvider);
    final options = ref.watch(libraryViewOptionsProvider);
    final progress = ref.watch(scanProgressProvider).value;
    final scanning = progress != null && !progress.isComplete;
    final notifier = ref.read(libraryProvider.notifier);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarsPageHeader(
            title: l10n.libraryTitle,
            actions: [
              IconButton(
                onPressed: () => _showOptions(context),
                tooltip: l10n.libraryOptions,
                icon: Icon(context.icons.sort),
              ),
              IconButton(
                onPressed: () async {
                  await notifier.triggerScan();
                },
                tooltip: l10n.rescanLibrary,
                icon: Icon(context.icons.refresh),
              ),
            ],
          ),
          const _LibraryTabs(),
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
                tracks: sortTracks(value, options.sort),
                showDuration: options.showDuration,
                currentTrackId: currentTrackId,
                isPlaying: isPlaying,
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

void _showOptions(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (context) => const LibraryOptionsSheet(),
  );
}

class _LibraryTabs extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            _LibraryTab(label: l10n.libraryTracks, active: true),
            const SizedBox(width: AppSpacing.xl),
            _LibraryTab(label: l10n.libraryPlaylists),
            const SizedBox(width: AppSpacing.xl),
            _LibraryTab(label: l10n.libraryArtists),
            const SizedBox(width: AppSpacing.xl),
            _LibraryTab(label: l10n.libraryAlbums),
          ],
        ),
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const new({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: active ? AppColors.textPrimary : AppColors.textMuted,
        ),
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
    required this.showDuration,
    required this.currentTrackId,
    required this.isPlaying,
    required this.onPlay,
    required this.onShuffleAll,
  });

  final List<Track> tracks;
  final bool showDuration;
  final String? currentTrackId;
  final bool isPlaying;
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
        final track = tracks[trackIndex];
        return TrackTile(
          track: track,
          showDuration: showDuration,
          isCurrent: track.id == currentTrackId,
          isPlaying: isPlaying,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              const Icon(
                AppIcons.shuffle,
                color: AppColors.textPrimary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.page),
              Text(
                l10n.shuffleAll.toUpperCase(),
                style: AppTextStyles.action.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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

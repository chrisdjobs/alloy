import 'dart:async';

import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/features/library/domain/track_sort.dart';
import 'package:alloy/features/library/presentation/library_notifier.dart';
import 'package:alloy/features/library/presentation/library_options_sheet.dart';
import 'package:alloy/features/library/presentation/library_view_options.dart';
import 'package:alloy/features/library/presentation/track_tile.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:alloy/shared/widgets/alloy_page_header.dart';
import 'package:alloy/shared/widgets/tbd_placeholder.dart';
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
class LibraryScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LibraryTab.values.length,
      vsync: this,
      initialIndex: LibraryTab.values.indexOf(ref.read(libraryTabProvider)),
    )..addListener(_syncSelectedTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Mirrors the section reached by a tap or a swipe into the provider.
  void _syncSelectedTab() {
    final tab = LibraryTab.values[_tabController.index];
    if (ref.read(libraryTabProvider) != tab) {
      ref.read(libraryTabProvider.notifier).select(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tracks = ref.watch(libraryProvider);
    final options = ref.watch(libraryViewOptionsProvider);
    final progress = ref.watch(scanProgressProvider).value;
    final scanning = progress != null && !progress.isComplete;
    final notifier = ref.read(libraryProvider.notifier);
    final searchActive = ref.watch(librarySearchActiveProvider);
    final query = ref.watch(librarySearchQueryProvider);

    // Keeps the bar in sync when another surface selects a section.
    ref.listen(libraryTabProvider, (previous, next) {
      if (_tabController.indexIsChanging) return;
      final index = LibraryTab.values.indexOf(next);
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlloyPageHeader(
            title: l10n.libraryTitle,
            center: searchActive ? const _LibrarySearchField() : null,
            actions: [
              IconButton(
                onPressed: () => _showOptions(context),
                tooltip: l10n.libraryOptions,
                icon: Icon(context.icons.sort),
              ),
              IconButton(
                onPressed: () => _toggleSearch(ref),
                tooltip: l10n.search,
                icon: Icon(context.icons.search),
              ),
              PopupMenuButton<_LibraryAction>(
                icon: Icon(context.icons.more),
                tooltip: l10n.moreOptions,
                onSelected: (action) {
                  switch (action) {
                    case _LibraryAction.rescan:
                      unawaited(notifier.triggerScan());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _LibraryAction.rescan,
                    child: Row(
                      children: [
                        Icon(
                          context.icons.refresh,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(l10n.rescanLibrary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            indicatorColor: AppColors.textPrimary,
            dividerColor: Colors.transparent,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.action,
            unselectedLabelStyle: AppTextStyles.action,
            tabs: [
              for (final tab in LibraryTab.values)
                Tab(text: _tabLabel(l10n, tab).toUpperCase()),
            ],
            onTap: (index) {
              ref
                  .read(libraryTabProvider.notifier)
                  .select(LibraryTab.values[index]);
            },
          ),
          if (scanning) const _ScanBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _tracksBody(tracks, options, query),
                const _ComingSoonTab(tab: LibraryTab.playlists),
                const _ComingSoonTab(tab: LibraryTab.artists),
                const _ComingSoonTab(tab: LibraryTab.albums),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tracksBody(
    AsyncValue<List<Track>> tracks,
    LibraryViewOptions options,
    String query,
  ) {
    final notifier = ref.read(libraryProvider.notifier);

    return switch (tracks) {
      AsyncValue(hasError: true) => _ErrorState(
        onRetry: () => ref.invalidate(libraryProvider),
      ),
      AsyncValue(hasValue: true, :final value?) when value.isEmpty =>
        _EmptyState(onChooseFolder: () => unawaited(notifier.scanFolder())),
      AsyncValue(:final value?) => _trackList(
        sortTracks(value, options.sort),
        options,
        query,
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _trackList(
    List<Track> sorted,
    LibraryViewOptions options,
    String query,
  ) {
    final filtered = _filterTracks(sorted, query);
    if (filtered.isEmpty && query.trim().isNotEmpty) {
      return const _NoResultsState();
    }

    return _TrackList(
      tracks: filtered,
      showDuration: options.showDuration,
      currentTrackId: widget.currentTrackId,
      isPlaying: widget.isPlaying,
      onPlay: widget.onPlay,
      onShuffleAll: widget.onShuffleAll,
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

void _toggleSearch(WidgetRef ref) {
  final active = ref.read(librarySearchActiveProvider);
  if (active) {
    ref.read(librarySearchQueryProvider.notifier).updateQuery('');
  }
  ref.read(librarySearchActiveProvider.notifier).setActive(!active);
}

/// Case-insensitive match of a query in the title, artist or album.
List<Track> _filterTracks(List<Track> tracks, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return tracks;

  return [
    for (final track in tracks)
      if (track.title.toLowerCase().contains(needle) ||
          (track.artist?.toLowerCase().contains(needle) ?? false) ||
          (track.album?.toLowerCase().contains(needle) ?? false))
        track,
  ];
}

class _LibrarySearchField extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_LibrarySearchField> createState() =>
      _LibrarySearchFieldState();
}

class _LibrarySearchFieldState extends ConsumerState<_LibrarySearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(librarySearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.clear();
    ref.read(librarySearchQueryProvider.notifier).updateQuery('');
    ref.read(librarySearchActiveProvider.notifier).setActive(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: (value) =>
          ref.read(librarySearchQueryProvider.notifier).updateQuery(value),
      style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: l10n.searchHint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        suffixIcon: IconButton(
          onPressed: _close,
          tooltip: l10n.close,
          icon: Icon(context.icons.close, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

String _tabLabel(AppLocalizations l10n, LibraryTab tab) {
  return switch (tab) {
    LibraryTab.tracks => l10n.libraryTracks,
    LibraryTab.playlists => l10n.libraryPlaylists,
    LibraryTab.artists => l10n.libraryArtists,
    LibraryTab.albums => l10n.libraryAlbums,
  };
}

class _ComingSoonTab extends StatelessWidget {
  const new({required this.tab});

  final LibraryTab tab;

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
            Text(_tabLabel(l10n, tab), style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.comingSoon,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(context.icons.search, size: 32, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.noSearchResults,
            style: AppTextStyles.title.copyWith(color: AppColors.textSecondary),
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Row(
            children: [
              Icon(
                context.icons.shuffle,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xl),
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
              icon: Icon(context.icons.folder),
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
                Icon(context.icons.error, color: AppColors.error, size: 32),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.error, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: Icon(context.icons.refresh),
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

enum _LibraryAction { rescan }

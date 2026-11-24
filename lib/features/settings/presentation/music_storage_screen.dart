import 'package:bars/features/library/domain/track.dart';
import 'package:bars/features/settings/presentation/widgets/settings_sub_screen.dart';
import 'package:bars/l10n/app_localizations.dart';
import 'package:bars/shared/design/text_styles.dart';
import 'package:bars/shared/design/tokens.dart';
import 'package:bars/shared/design/visual_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Where the library comes from: folder picker, rescan and track counts.
class MusicStorageScreen extends StatelessWidget {
  /// Creates the screen.
  const new({
    required this.tracks,
    required this.onChooseFolder,
    required this.onRescan,
    super.key,
  });

  /// Library tracks and their load state.
  final AsyncValue<List<Track>> tracks;

  /// Opens the folder picker.
  final VoidCallback onChooseFolder;

  /// Rescans the folder chosen before.
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = tracks.value;

    return SettingsSubScreen(
      title: l10n.musicAndStorageTitle,
      children: [
        if (library != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: _LibraryCard(
              trackCount: library.length,
              albumCount: _albums(library),
            ),
          ),
        SettingsSection(title: l10n.musicFolders, accent: true),
        SettingsRow(
          icon: context.icons.folder,
          title: l10n.chooseFolder,
          subtitle: l10n.chooseFolderHint,
          onTap: onChooseFolder,
        ),
        SettingsRow(
          icon: context.icons.refresh,
          title: l10n.rescanLibrary,
          subtitle: l10n.rescanLibraryHint,
          onTap: onRescan,
        ),
      ],
    );
  }
}

int _albums(List<Track> tracks) {
  return tracks.map((track) => track.album).whereType<String>().toSet().length;
}

/// Surface card with the size of the local library.
class _LibraryCard extends StatelessWidget {
  const new({required this.trackCount, required this.albumCount});

  final int trackCount;
  final int albumCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.trackCount(trackCount), style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.albumCount(albumCount),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

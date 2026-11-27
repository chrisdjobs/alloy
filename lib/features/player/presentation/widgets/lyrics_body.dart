import 'package:alloy/features/library/domain/lyrics_provider_ref.dart';
import 'package:alloy/features/library/domain/track.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:alloy/shared/design/visual_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lyrics_body.g.dart';

/// Body that shows the lyrics of the current track.
class LyricsBody extends ConsumerWidget {
  /// Creates the body for [track].
  const new({required this.track, super.key});

  /// Track whose lyrics are shown.
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lyricsAsync = ref.watch(trackLyricsProvider(track));

    return switch (lyricsAsync) {
      AsyncData(:final value) =>
        value == null || value.trim().isEmpty
            ? _NoLyricsState(l10n: l10n)
            : _LyricsContent(lyrics: value),
      AsyncError() => _ErrorState(l10n: l10n),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// Lyrics stored for [track], or `null` when the track has none.
@riverpod
Future<String?> trackLyrics(Ref ref, Track track) async {
  final provider = ref.read(lyricsProvider);
  final result = await provider.lyricsFor(track);
  return result.valueOrNull;
}

class _LyricsContent extends StatelessWidget {
  const new({required this.lyrics});

  final String lyrics;

  @override
  Widget build(BuildContext context) {
    // Check if lyrics look like LRC (have timestamps like [00:12.34])
    final isSynced = RegExp(r'\[\d{2}:\d{2}\.\d{2,3}\]').hasMatch(lyrics);
    final lines = isSynced ? _parseLrc(lyrics) : lyrics.split('\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(
        lines.join('\n'),
        style: AppTextStyles.lyrics.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  List<String> _parseLrc(String lrc) {
    // Strip timestamps like [00:12.34] from each line
    return [
      for (final line in lrc.split('\n'))
        line.replaceFirst(RegExp(r'^\[\d{2}:\d{2}\.\d{2,3}\]\s*'), ''),
    ];
  }
}

class _NoLyricsState extends StatelessWidget {
  const new({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(context.icons.lyrics, size: 48, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.lyricsNone,
            style: AppTextStyles.title.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const new({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(context.icons.error, size: 32, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.error,
            style: AppTextStyles.title.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

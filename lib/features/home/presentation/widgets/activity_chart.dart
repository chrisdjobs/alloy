import 'dart:math' as math;

import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/features/home/presentation/widgets/listening_duration.dart';
import 'package:alloy/l10n/app_localizations.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Bar chart of the plays of the last days, drawn inside a surface card.
///
/// The headline figures of [summary] sit above the bars. The week window
/// labels every bar with its weekday initial; the month window marks every
/// fifth day to stay readable.
class ActivityChart extends StatelessWidget {
  /// Creates the chart for [points] and [summary] of the active [period].
  const new({
    required this.points,
    required this.summary,
    required this.period,
    super.key,
  });

  /// One bar per day, oldest first.
  final List<ActivityPoint> points;

  /// Headline figures above the bars.
  final ActivitySummary summary;

  /// Active statistics window.
  final HomePeriod period;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final weekday = DateFormat(
      'E',
      Localizations.localeOf(context).toLanguageTag(),
    );
    final maxPlays = points.fold<int>(
      0,
      (max, point) => math.max(max, point.plays),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  _SummaryStat(
                    value: formatListeningDuration(l10n, summary.today),
                    label: l10n.today,
                  ),
                  _SummaryStat(
                    value: formatListeningDuration(l10n, summary.thisWeek),
                    label: l10n.thisWeek,
                  ),
                  _SummaryStat(
                    value: l10n.dayCount(summary.streakDays),
                    label: l10n.streak,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: AppSizing.activityChartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: AppSizing.activityBarGap,
                  children: [
                    for (final point in points)
                      Expanded(
                        child: _Bar(
                          height: _height(point, maxPlays),
                          color: point.plays == 0 ? AppColors.outline : accent,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                spacing: AppSizing.activityBarGap,
                children: [
                  if (period == HomePeriod.week)
                    for (final point in points)
                      Expanded(
                        child: _label(
                          weekday
                              .format(point.date)
                              .substring(0, 1)
                              .toUpperCase(),
                        ),
                      )
                  else
                    for (var start = 0; start < points.length; start += 5)
                      Expanded(
                        flex: math.min(5, points.length - start),
                        child: _label('${_groupEnd(start).date.day}'),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _height(ActivityPoint point, int maxPlays) {
    if (maxPlays == 0) return AppSizing.activityBarMinHeight;
    final scaled = point.plays / maxPlays * AppSizing.activityChartHeight;
    return math.max(AppSizing.activityBarMinHeight, scaled);
  }

  Widget _label(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
    );
  }

  /// Last day of the five-day group that starts at [start].
  ActivityPoint _groupEnd(int start) {
    return points[math.min(start + 4, points.length - 1)];
  }
}

class _Bar extends StatelessWidget {
  const new({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.activityBar,
      ),
      child: SizedBox(height: height),
    );
  }
}

/// One headline figure of the activity card: value on top, label below.
class _SummaryStat extends StatelessWidget {
  const new({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.trackTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.trackArtist.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

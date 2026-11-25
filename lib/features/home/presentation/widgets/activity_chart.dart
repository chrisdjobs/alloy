import 'dart:math' as math;

import 'package:alloy/features/home/domain/home_sections.dart';
import 'package:alloy/shared/design/text_styles.dart';
import 'package:alloy/shared/design/tokens.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Bar chart of the plays of the last days, drawn inside a surface card.
///
/// The week window labels every bar with its weekday initial; the month window
/// labels every fifth day to stay readable.
class ActivityChart extends StatelessWidget {
  /// Creates the chart for [points] of the active [period].
  const new({required this.points, required this.period, super.key});

  /// One bar per day, oldest first.
  final List<ActivityPoint> points;

  /// Active statistics window.
  final HomePeriod period;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

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
                  for (var i = 0; i < points.length; i++)
                    Expanded(
                      child: Text(
                        _label(points[i], i, weekday),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
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

  String _label(ActivityPoint point, int index, DateFormat weekday) {
    if (period == HomePeriod.week) {
      return weekday.format(point.date).substring(0, 1).toUpperCase();
    }
    final isMarked = index % 5 == 0 || index == points.length - 1;
    return isMarked ? '${point.date.day}' : '';
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

import 'package:alloy/l10n/app_localizations.dart';

/// Formats listening time, such as "26 h", "1 h 07 min" or "42 min".
///
/// Used by the Home statistics surfaces; track lengths use
/// `formatTrackDuration` instead, which renders "m:ss".
String formatListeningDuration(AppLocalizations l10n, Duration duration) {
  final hours = duration.inHours;
  if (hours == 0) return l10n.durationMinutes(duration.inMinutes);
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return l10n.durationHoursMinutes(hours, minutes);
}

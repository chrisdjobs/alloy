/// Formats [duration] as "m:ss", or "h:mm:ss" once it reaches an hour.
///
/// A missing duration renders as the placeholder "--:--" instead of failing:
/// sources are allowed to report tracks without a length.
String formatTrackDuration(Duration? duration) {
  if (duration == null) return '--:--';
  final seconds = duration.inSeconds;
  final minutes = seconds ~/ 60;
  final remainder = (seconds % 60).toString().padLeft(2, '0');
  final hours = minutes ~/ 60;
  if (hours == 0) return '$minutes:$remainder';
  return '$hours:${(minutes % 60).toString().padLeft(2, '0')}:$remainder';
}

import 'dart:developer' as developer;

/// Application logger backed by `dart:developer`.
///
/// Using this facade instead of `print` keeps output out of stdout and makes
/// every entry visible in the DevTools log with a consistent name.
abstract final class Logger {
  static const _name = 'alloy';
  static const _debugLevel = 500;
  static const _infoLevel = 800;
  static const _warningLevel = 900;
  static const _errorLevel = 1000;

  /// Logs a debug message.
  static void debug(String message, {String name = _name}) {
    developer.log(message, name: name, level: _debugLevel);
  }

  /// Logs an informational message.
  static void info(String message, {String name = _name}) {
    developer.log(message, name: name, level: _infoLevel);
  }

  /// Logs a recoverable problem.
  static void warning(String message, {String name = _name}) {
    developer.log(message, name: name, level: _warningLevel);
  }

  /// Logs an error with its cause and stack trace when available.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = _name,
  }) {
    developer.log(
      message,
      name: name,
      level: _errorLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

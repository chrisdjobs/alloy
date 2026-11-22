/// Recoverable error returned by domain operations.
///
/// Failures never cross a layer boundary as exceptions; they travel inside a
/// `Result`. Use the named constructors to build the concrete subtype without
/// importing it directly.
sealed class Failure {
  const new _({this.message, this.cause, this.stackTrace});

  /// Creates an I/O failure.
  const factory io({String? message, Object? cause, StackTrace? stackTrace}) =
      IoFailure;

  /// Creates a failure while decoding or parsing data.
  const factory parse({
    String? message,
    Object? cause,
    StackTrace? stackTrace,
  }) = ParseFailure;

  /// Creates a failure caused by a missing or denied permission.
  const factory permission({
    String? message,
    Object? cause,
    StackTrace? stackTrace,
  }) = PermissionFailure;

  /// Creates a failure for missing data or files.
  const factory notFound({
    String? message,
    Object? cause,
    StackTrace? stackTrace,
  }) = NotFoundFailure;

  /// Creates a failure without a more specific category.
  const factory unknown({
    String? message,
    Object? cause,
    StackTrace? stackTrace,
  }) = UnknownFailure;

  /// Human readable detail for diagnostics and, when safe, for the UI.
  final String? message;

  /// Underlying error, kept for logging.
  final Object? cause;

  /// Stack trace of the underlying error, kept for logging.
  final StackTrace? stackTrace;
}

/// Failure while reading or writing local data.
final class IoFailure extends Failure {
  /// Creates an I/O failure.
  const new({super.message, super.cause, super.stackTrace}) : super._();
}

/// Failure while decoding or parsing data.
final class ParseFailure extends Failure {
  /// Creates a parse failure.
  const new({super.message, super.cause, super.stackTrace}) : super._();
}

/// Failure caused by a missing or denied permission.
final class PermissionFailure extends Failure {
  /// Creates a permission failure.
  const new({super.message, super.cause, super.stackTrace}) : super._();
}

/// Failure for missing data or files.
final class NotFoundFailure extends Failure {
  /// Creates a not-found failure.
  const new({super.message, super.cause, super.stackTrace}) : super._();
}

/// Failure without a more specific category.
final class UnknownFailure extends Failure {
  /// Creates an unknown failure.
  const new({super.message, super.cause, super.stackTrace}) : super._();
}

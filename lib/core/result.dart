import 'package:bars/core/failure.dart';

/// Outcome of a domain operation: either a value or a [Failure].
sealed class Result<T> {
  const new _();

  /// Creates a successful result carrying [value].
  const factory ok(T value) = Ok<T>;

  /// Creates a failed result carrying [failure].
  const factory err(Failure failure) = Err<T>;

  /// Whether this is an [Ok].
  bool get isOk => this is Ok<T>;

  /// Whether this is an [Err].
  bool get isErr => this is Err<T>;

  /// The value when successful, otherwise `null`.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// The failure when unsuccessful, otherwise `null`.
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  /// Collapses both branches into a single value.
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) => switch (this) {
    Ok<T>(:final value) => onOk(value),
    Err<T>(:final failure) => onErr(failure),
  };
}

/// Successful [Result] carrying a value.
final class Ok<T> extends Result<T> {
  /// Creates a successful result.
  const new(this.value) : super._();

  /// The value produced by the operation.
  final T value;

  @override
  String toString() => 'Ok<$T>($value)';
}

/// Failed [Result] carrying a [Failure].
final class Err<T> extends Result<T> {
  /// Creates a failed result.
  const new(this.failure) : super._();

  /// Why the operation failed.
  final Failure failure;

  @override
  String toString() => 'Err<$T>($failure)';
}

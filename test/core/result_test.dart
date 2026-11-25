import 'package:alloy/core/failure.dart';
import 'package:alloy/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok carries a value and folds to the success branch', () {
      const result = Result<int>.ok(42);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
      expect(result.fold(onOk: (value) => value * 2, onErr: (_) => -1), 84);
    });

    test('Err carries a failure and folds to the error branch', () {
      const failure = Failure.notFound(message: 'missing');
      const result = Result<int>.err(failure);

      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
      expect(
        result.fold(
          onOk: (value) => value,
          onErr: (failure) => failure.message,
        ),
        'missing',
      );
    });

    test('pattern matching is exhaustive', () {
      const result = Result.ok('alloy');

      final description = switch (result) {
        Ok(:final value) => value,
        Err(:final failure) => failure.message ?? 'failure',
      };

      expect(description, 'alloy');
    });

    test('exposes the concrete branch', () {
      const ok = Result<int>.ok(1);
      const err = Result<int>.err(Failure.io(message: 'disk'));

      expect(ok, isA<Ok<int>>());
      expect((ok as Ok<int>).value, 1);
      expect(err, isA<Err<int>>());
      expect((err as Err<int>).failure.message, 'disk');
    });
  });
}

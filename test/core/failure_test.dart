import 'package:bars/core/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('named constructors create the matching subtype', () {
      expect(const Failure.io(), isA<IoFailure>());
      expect(const Failure.parse(), isA<ParseFailure>());
      expect(const Failure.permission(), isA<PermissionFailure>());
      expect(const Failure.notFound(), isA<NotFoundFailure>());
      expect(const Failure.unknown(), isA<UnknownFailure>());
    });

    test('keeps the message and cause for diagnostics', () {
      final cause = StateError('boom');
      final failure = Failure.io(message: 'cannot read folder', cause: cause);

      expect(failure.message, 'cannot read folder');
      expect(failure.cause, same(cause));
    });

    test('subtypes can be matched exhaustively', () {
      final label = switch (const Failure.permission(message: 'denied')) {
        IoFailure() => 'io',
        ParseFailure() => 'parse',
        PermissionFailure(:final message) => message,
        NotFoundFailure() => 'not found',
        UnknownFailure() => 'unknown',
      };

      expect(label, 'denied');
    });
  });
}

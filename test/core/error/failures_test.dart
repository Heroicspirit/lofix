import 'package:flutter_test/flutter_test.dart';
import 'package:musicapp/core/error/failures.dart';

void main() {
  group('Failure Classes', () {
    group('Failure', () {
      test('should create Failure with message', () {
        // Arrange
        const message = 'Test failure message';

        // Act
        final failure = TestFailure(message);

        // Assert
        expect(failure.message, equals(message));
      });

      test('should have correct props', () {
        // Arrange
        const message = 'Test failure message';
        final failure1 = TestFailure(message);
        final failure2 = TestFailure(message);
        final failure3 = TestFailure('Different message');

        // Act & Assert
        expect(failure1.props, equals([message]));
        expect(failure1 == failure2, isTrue);
        expect(failure1 == failure3, isFalse);
      });
    });

    group('LocalDatabaseFailure', () {
      test('should create LocalDatabaseFailure with default message', () {
        // Act
        final failure = const LocalDatabaseFailure();

        // Assert
        expect(failure.message, equals('Local database opertaion failed'));
      });

      test('should create LocalDatabaseFailure with custom message', () {
        // Arrange
        const customMessage = 'Custom database error';

        // Act
        final failure = const LocalDatabaseFailure(message: customMessage);

        // Assert
        expect(failure.message, equals(customMessage));
      });

      test('should have correct props', () {
        // Arrange
        const message = 'Database error';
        final failure1 = const LocalDatabaseFailure(message: message);
        final failure2 = const LocalDatabaseFailure(message: message);
        final failure3 = const LocalDatabaseFailure(message: 'Different error');

        // Act & Assert
        expect(failure1.props, equals([message]));
        expect(failure1 == failure2, isTrue);
        expect(failure1 == failure3, isFalse);
      });
    });

    group('ApiFailure', () {
      test('should create ApiFailure with message and status code', () {
        // Arrange
        const message = 'API error occurred';
        const statusCode = 404;

        // Act
        final failure = const ApiFailure(message: message, statusCode: statusCode);

        // Assert
        expect(failure.message, equals(message));
        expect(failure.statusCode, equals(statusCode));
      });

      test('should create ApiFailure with only message', () {
        // Arrange
        const message = 'API error occurred';

        // Act
        final failure = const ApiFailure(message: message);

        // Assert
        expect(failure.message, equals(message));
        expect(failure.statusCode, isNull);
      });

      test('should have correct props', () {
        // Arrange
        const message = 'API error';
        const statusCode = 500;
        final failure1 = const ApiFailure(message: message, statusCode: statusCode);
        final failure2 = const ApiFailure(message: message, statusCode: statusCode);
        final failure3 = const ApiFailure(message: message, statusCode: 404);
        final failure4 = const ApiFailure(message: 'Different error', statusCode: statusCode);

        // Act & Assert
        expect(failure1.props, equals([message, statusCode]));
        expect(failure1 == failure2, isTrue);
        expect(failure1 == failure3, isFalse);
        expect(failure1 == failure4, isFalse);
      });

      test('should handle null status code in props', () {
        // Arrange
        const message = 'API error';
        final failure1 = const ApiFailure(message: message);
        final failure2 = const ApiFailure(message: message);

        // Act & Assert
        expect(failure1.props, equals([message, null]));
        expect(failure1 == failure2, isTrue);
      });
    });
  });
}

// Test helper class for abstract Failure class
class TestFailure extends Failure {
  const TestFailure(super.message);
}

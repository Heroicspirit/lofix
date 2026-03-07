import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/usecases/app_usecase.dart';

// Mock implementation for testing
class MockAppUsecase implements UsecaseWithoutParams<String> {
  @override
  Future<Either<Failure, String>> call() async {
    return const Right('Mock Result');
  }
}

class MockAppUsecaseWithParams implements UsecaseWithParams<String, String> {
  @override
  Future<Either<Failure, String>> call(String params) async {
    return Right('Mock Result: $params');
  }
}

void main() {
  group('AppUsecase Interfaces', () {
    test('UsecaseWithoutParams should work without parameters', () async {
      // Arrange
      final usecase = MockAppUsecase();

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right('Mock Result'));
    });

    test('UsecaseWithParams should work with parameters', () async {
      // Arrange
      final usecase = MockAppUsecaseWithParams();
      const testParam = 'Test Parameter';

      // Act
      final result = await usecase(testParam);

      // Assert
      expect(result, Right('Mock Result: $testParam'));
    });

    test('UsecaseWithoutParams should handle failures', () async {
      // Arrange
      final usecase = MockFailingUsecase();

      // Act
      final result = await usecase();

      // Assert
      expect(result, isA<Left<Failure, String>>());
    });

    test('UsecaseWithParams should handle failures with parameters', () async {
      // Arrange
      final usecase = MockFailingUsecaseWithParams();
      const testParam = 'Test Parameter';

      // Act
      final result = await usecase(testParam);

      // Assert
      expect(result, isA<Left<Failure, String>>());
    });
  });
}

// Mock failing implementations for failure testing
class MockFailingUsecase implements UsecaseWithoutParams<String> {
  @override
  Future<Either<Failure, String>> call() async {
    return const Left(ApiFailure(message: 'Test failure'));
  }
}

class MockFailingUsecaseWithParams implements UsecaseWithParams<String, String> {
  @override
  Future<Either<Failure, String>> call(String params) async {
    return Left(ApiFailure(message: 'Test failure with params: $params'));
  }
}

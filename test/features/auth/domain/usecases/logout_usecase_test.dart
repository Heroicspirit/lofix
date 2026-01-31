import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/usecases/logout_usecase.dart';

// 1. Mock the Repository Interface
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: mockAuthRepository);
  });

  group('LogoutUsecase Unit Tests', () {
    test('should call logout on the repository', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase();

      // Assert
      // Verify that the repository method was called exactly once
      verify(() => mockAuthRepository.logout()).called(1);
      expect(result, const Right(true));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return true when logout is successful', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(true));
    });

    test('should return Failure when repository logout fails', () async {
      // Arrange
      final tFailure = ApiFailure(message: "Logout failed");
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}
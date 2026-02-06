import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/usecases/get_current_usecase.dart';


// 1. Mock the Repository Interface
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(authRepository: mockAuthRepository);
  });

  // Mock Data
  const tAuthEntity = AuthEntity(
    email: 'session@user.com',
    name: 'Session User',
  );

  group('GetCurrentUserUsecase Unit Tests', () {
    test('should call getCurrentUser on the repository', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await usecase();

      // Assert
      // Verify the method was called exactly once with no arguments
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthEntity when repository successfully fetches user', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tAuthEntity));
    });

    test('should return Failure when repository fails to fetch user', () async {
      // Arrange
      final tFailure = ApiFailure(message: 'No session found');
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(tFailure));
    });
  });
}
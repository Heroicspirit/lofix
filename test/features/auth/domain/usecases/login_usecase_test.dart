import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/usecases/login_usecase.dart';

// 1. Mock the Repository Interface
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  // Test Data
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tParams = LoginUsecaseParams(email: tEmail, password: tPassword);

  // 2. Updated Entity - Removed 'id' and 'token' to fix your error.
  // Match these exactly to your AuthEntity constructor.
  const tAuthEntity = AuthEntity(
    email: tEmail,
    name: 'Test User',
  );

  group('LoginUsecase Unit Tests', () {
    test('should call login on the repository with correct parameters', () async {
      // Arrange
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await usecase(tParams);

      // Assert
      // Verify that the usecase passed the strings correctly to the repository
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    });

    test('should return AuthEntity when repository login is successful', () async {
      // Arrange
      when(() => mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase(tParams);

      // Assert
      // Using dartz 'Right' to check for success
      expect(result, const Right(tAuthEntity));
    });

    test('should return Failure when repository login fails', () async {
      // Arrange
      final tFailure = ApiFailure(message: 'Invalid Credentials');
      when(() => mockAuthRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      // Using dartz 'Left' to check for failure
      expect(result, Left(tFailure));
    });
  });
}
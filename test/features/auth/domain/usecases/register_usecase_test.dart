import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/usecases/register_usecase.dart';

// 1. Mock the Repository
class MockAuthRepository extends Mock implements IAuthRepository {}

// 2. Create a Fake for AuthEntity since it's passed as an argument in the Repository
class FakeAuthEntity extends Fake implements AuthEntity {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    // Register fallback for the custom entity type
    registerFallbackValue(FakeAuthEntity());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  // Test Data
  const tParams = RegisterUsecaseParams(
    email: "test@example.com",
    name: "Test User",
    password: "password123",
  );

  group('RegisterUsecase Unit Tests', () {
    test('should call register on repository with an AuthEntity', () async {
      // Arrange
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      // We verify 'any()' because the Usecase creates a NEW instance of AuthEntity inside 'call'
      verify(() => mockAuthRepository.register(any())).called(1);
      expect(result, const Right(true));
    });

    test('should return true when registration is successful', () async {
      // Arrange
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
    });

    test('should return Failure when repository registration fails', () async {
      // Arrange
      final tFailure = ApiFailure(message: "Registration Failed");
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(tFailure));
    });
  });
}
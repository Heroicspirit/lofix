import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/features/auth/data/datasources/auth_datasource.dart';
import 'package:musicapp/features/auth/data/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/services/connectivity/network_info.dart';
import 'package:musicapp/features/auth/data/models/auth_api_model.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class AuthApiModelFake extends Fake implements AuthApiModel {
  @override
  String? get authId => 'fake-id';
  @override
  String get email => 'fake@email.com';
  @override
  String get name => 'Fake User';
  @override
  String? get password => 'fake-password';
  @override
  String? get confirmPassword => null;
  @override
  String? get profilePicture => null;
}

class AuthHiveModelFake extends Fake implements AuthHiveModel {
  @override
  String? get authId => 'fake-id';
  @override
  String get email => 'fake@email.com';
  @override
  String get name => 'Fake User';
  @override
  String? get password => 'fake-password';
  @override
  String? get profilePicture => null;
}

class AuthEntityFake extends Fake implements AuthEntity {
  @override
  String? get authId => 'fake-id';
  @override
  String get email => 'fake@email.com';
  @override
  String get name => 'Fake User';
  @override
  String? get password => 'fake-password';
  @override
  String? get confirmPassword => null;
  @override
  String? get profilePicture => null;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(AuthApiModelFake());
    registerFallbackValue(AuthHiveModelFake());
    registerFallbackValue(AuthEntityFake());
  });

  group('AuthRepository', () {
    late AuthRepository repository;
    late MockAuthRemoteDataSource mockRemoteDataSource;
    late MockAuthLocalDataSource mockLocalDataSource;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      mockLocalDataSource = MockAuthLocalDataSource();
      repository = AuthRepository(
        authDatasource: mockLocalDataSource,
        authRemoteDataSource: mockRemoteDataSource,
        networkInfo: MockNetworkInfo(),
      );
    });

    group('login', () {
      test('should return AuthEntity when remote login succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final authApiModel = AuthApiModel(
          authId: 'user-123',
          email: email,
          name: 'Test User',
        );
        
        when(() => mockRemoteDataSource.login(email, password))
            .thenAnswer((_) async => authApiModel as dynamic);

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure'),
          (authEntity) {
            expect(authEntity.email, equals(email));
            expect(authEntity.name, equals('Test User'));
          },
        );
        verify(() => mockRemoteDataSource.login(email, password)).called(1);
      });

      test('should return Left when remote login returns null', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong-password';
        
        when(() => mockRemoteDataSource.login(email, password))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure.message, equals('Invalid Credentials')),
          (authEntity) => fail('Expected failure but got success'),
        );
        verify(() => mockRemoteDataSource.login(email, password)).called(1);
      });

      test('should propagate exception when remote data source throws', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong-password';
        
        when(() => mockRemoteDataSource.login(email, password))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.login(email, password);

        // Assert
        expect(result.isLeft(), isTrue);
        verify(() => mockRemoteDataSource.login(email, password)).called(1);
      });
    });

    group('register', () {
      test('should return Right(true) when register succeeds', () async {
        // Arrange
        final authEntity = AuthEntity(
          authId: 'user-456',
          email: 'test@example.com',
          name: 'Test User',
        );
        final authApiModel = AuthApiModel(
          authId: 'user-456',
          email: 'test@example.com',
          name: 'Test User',
        );
        
        when(() => mockRemoteDataSource.register(any()))
            .thenAnswer((_) async => authApiModel as dynamic);

        // Act
        final result = await repository.register(authEntity);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure'),
          (success) => expect(success, isTrue),
        );
        verify(() => mockRemoteDataSource.register(any())).called(1);
      });

      test('should return Left when register fails', () async {
        // Arrange
        final authEntity = AuthEntity(
          authId: 'user-456',
          email: 'existing@example.com',
          name: 'Test User',
        );
        
        when(() => mockRemoteDataSource.register(any()))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/auth/register'),
              type: DioExceptionType.badResponse,
              message: 'Email already exists',
            ));

        // Act
        final result = await repository.register(authEntity);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ApiFailure>()),
          (success) => fail('Expected failure but got success'),
        );
        verify(() => mockRemoteDataSource.register(any())).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return AuthEntity when get current user succeeds', () async {
        // Arrange
        final authHiveModel = AuthHiveModel(
          authId: 'user-123',
          email: 'test@example.com',
          name: 'Test User',
        );
        
        when(() => mockLocalDataSource.getCurrentUser())
            .thenAnswer((_) async => authHiveModel as dynamic);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure'),
          (authEntity) {
            expect(authEntity.email, equals('test@example.com'));
            expect(authEntity.name, equals('Test User'));
          },
        );
        verify(() => mockLocalDataSource.getCurrentUser()).called(1);
      });

      test('should return Left when no user logged in', () async {
        // Arrange
        when(() => mockLocalDataSource.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<LocalDatabaseFailure>()),
          (authEntity) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.getCurrentUser()).called(1);
      });

      test('should return Left when data source throws', () async {
        // Arrange
        when(() => mockLocalDataSource.getCurrentUser())
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<LocalDatabaseFailure>()),
          (authEntity) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.getCurrentUser()).called(1);
      });
    });

    group('logout', () {
      test('should return Right(true) when logout succeeds', () async {
        // Arrange
        when(() => mockLocalDataSource.logout())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure'),
          (success) => expect(success, isTrue),
        );
        verify(() => mockLocalDataSource.logout()).called(1);
      });

      test('should return Left when logout fails', () async {
        // Arrange
        when(() => mockLocalDataSource.logout())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<LocalDatabaseFailure>()),
          (success) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.logout()).called(1);
      });
    });
  });
}

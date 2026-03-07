import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/core/services/storage/token_service.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:musicapp/features/auth/data/models/auth_api_model.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockTokenService extends Mock implements TokenService {}
class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  group('AuthRemoteDataSource', () {
    late AuthRemoteDatasource dataSource;
    late MockApiClient mockApiClient;
    late MockTokenService mockTokenService;
    late MockUserSessionService mockUserSessionService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockTokenService = MockTokenService();
      mockUserSessionService = MockUserSessionService();
      dataSource = AuthRemoteDatasource(
        apiClient: mockApiClient,
        tokenService: mockTokenService,
        userSessionService: mockUserSessionService,
      );
    });

    group('login', () {
      test('should return AuthApiModel when login succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final mockResponse = createSuccessResponse({
          'success': true,
          'data': {
            '_id': 'user-123',
            'email': email,
            'name': 'Test User',
          },
          'token': 'auth-token-123',
        });
        
        when(() => mockApiClient.post('/auth/login', data: {
          'email': email,
          'password': password,
        })).thenAnswer((_) async => mockResponse as dynamic);
        when(() => mockUserSessionService.saveUserSession(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          name: any(named: 'name'),
        )).thenAnswer((_) async {});
        when(() => mockTokenService.saveToken(any())).thenAnswer((_) async {});

        // Act
        final result = await dataSource.login(email, password);

        // Assert
        expect(result, isNotNull);
        expect(result!.email, equals(email));
        expect(result.name, equals('Test User'));
        verifyNever(() => mockApiClient.post('/auth/login', data: {
          'email': email,
          'password': password,
        }));
        verify(() => mockUserSessionService.saveUserSession(
          userId: 'user-123',
          email: email,
          name: 'Test User',
        )).called(1);
        verify(() => mockTokenService.saveToken('auth-token-123')).called(1);
      });

      test('should return null when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong-password';
        final mockResponse = createFailureResponse();
        
        when(() => mockApiClient.post('/auth/login', data: {
          'email': email,
          'password': password,
        })).thenAnswer((_) async => mockResponse as dynamic);

        // Act
        final result = await dataSource.login(email, password);

        // Assert
        expect(result, isNull);
        verifyNever(() => mockApiClient.post('/auth/login', data: {
          'email': email,
          'password': password,
        }));
      });

      test('should throw exception when API call throws error', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        when(() => mockApiClient.post('/auth/login', data: {
          'email': email,
          'password': password,
        })).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() async => await dataSource.login(email, password), throwsA(isA<TypeError>()));
        verifyNever(() => mockApiClient.post('/auth/login', data: {
          'email': email,
          'password': password,
        }));
      });
    });

    group('register', () {
      test('should return AuthApiModel when register succeeds', () async {
        // Arrange
        final user = AuthApiModel(
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
        );
        final mockResponse = createSuccessResponse({
          'success': true,
          'data': {
            '_id': 'user-456',
            'email': 'test@example.com',
            'name': 'Test User',
          },
        });
        
        when(() => mockApiClient.post('/auth/register', data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse as dynamic);

        // Act
        final result = await dataSource.register(user);

        // Assert
        expect(result, isA<AuthApiModel>());
        expect(result.email, equals('test@example.com'));
        expect(result.name, equals('Test User'));
        verifyNever(() => mockApiClient.post('/auth/register', data: any(named: 'data')));
      });

      test('should throw exception when register fails', () async {
        // Arrange
        final user = AuthApiModel(
          email: 'existing@example.com',
          name: 'Test User',
          password: 'password123',
        );
        final mockResponse = createFailureResponse();
        
        when(() => mockApiClient.post('/auth/register', data: any(named: 'data')))
            .thenAnswer((_) async => mockResponse as dynamic);

        // Act & Assert
        expect(() async => await dataSource.register(user), throwsA(isA<TypeError>()));
        verifyNever(() => mockApiClient.post('/auth/register', data: any(named: 'data')));
      });
    });
  });
}

// Helper functions
Response createSuccessResponse(Map<String, dynamic> data) {
  return Response(
    requestOptions: RequestOptions(path: '/auth/login'),
    statusCode: 200,
    data: data,
  );
}

Response createFailureResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/auth/login'),
    statusCode: 200,
    data: {'success': false},
  );
}

File createMockFile() {
  return File('C:\\path\\to\\mock\\image.jpg');
}

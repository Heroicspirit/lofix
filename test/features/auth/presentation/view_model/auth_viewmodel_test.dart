import 'package:flutter_test/flutter_test.dart';

import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';

void main() {
  group('AuthState Tests', () {
    test('should create initial state correctly', () {
      // Act
      final state = AuthState.initial();

      // Assert
      expect(state.status, equals(AuthStatus.initial));
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
      expect(state.uploadPhotoName, isNull);
    });

    test('should handle copyWith correctly', () {
      // Arrange
      const originalState = AuthState(
        status: AuthStatus.initial,
        authEntity: null,
        errorMessage: null,
        uploadPhotoName: null,
      );

      // Act
      final newState = originalState.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: 'Test error',
      );

      // Assert
      expect(newState.status, equals(AuthStatus.authenticated));
      expect(newState.errorMessage, equals('Test error'));
      expect(newState.authEntity, isNull);
      expect(newState.uploadPhotoName, isNull);
    });

    test('should handle equality correctly', () {
      // Arrange
      const state1 = AuthState(
        status: AuthStatus.initial,
        authEntity: null,
        errorMessage: null,
        uploadPhotoName: null,
      );

      const state2 = AuthState(
        status: AuthStatus.initial,
        authEntity: null,
        errorMessage: null,
        uploadPhotoName: null,
      );

      const state3 = AuthState(
        status: AuthStatus.authenticated,
        authEntity: null,
        errorMessage: null,
        uploadPhotoName: null,
      );

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('should handle props correctly', () {
      // Arrange
      const authEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: null,
        confirmPassword: null,
        profilePicture: null,
      );

      const state = AuthState(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
        errorMessage: 'Error message',
        uploadPhotoName: 'photo.jpg',
      );

      // Act
      final props = state.props;

      // Assert
      expect(props.length, equals(4));
      expect(props[0], equals(AuthStatus.authenticated));
      expect(props[1], equals(authEntity));
      expect(props[2], equals('Error message'));
      expect(props[3], equals('photo.jpg'));
    });
  });

  group('AuthEntity Tests', () {
    test('should create AuthEntity correctly', () {
      // Act
      const authEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        confirmPassword: 'password123',
        profilePicture: 'profile.jpg',
      );

      // Assert
      expect(authEntity.authId, equals('123'));
      expect(authEntity.email, equals('test@example.com'));
      expect(authEntity.name, equals('Test User'));
      expect(authEntity.password, equals('password123'));
      expect(authEntity.confirmPassword, equals('password123'));
      expect(authEntity.profilePicture, equals('profile.jpg'));
    });

    test('should handle copyWith correctly', () {
      // Arrange
      const originalEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        confirmPassword: 'password123',
        profilePicture: 'profile.jpg',
      );

      // Act
      final updatedEntity = originalEntity.copyWith(
        name: 'Updated User',
        profilePicture: 'new_profile.jpg',
      );

      // Assert
      expect(updatedEntity.authId, equals('123'));
      expect(updatedEntity.email, equals('test@example.com'));
      expect(updatedEntity.name, equals('Updated User'));
      expect(updatedEntity.password, equals('password123'));
      expect(updatedEntity.confirmPassword, equals('password123'));
      expect(updatedEntity.profilePicture, equals('new_profile.jpg'));
    });

    test('should handle equality correctly', () {
      // Arrange
      const entity1 = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        confirmPassword: 'password123',
        profilePicture: 'profile.jpg',
      );

      const entity2 = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        confirmPassword: 'password123',
        profilePicture: 'profile.jpg',
      );

      const entity3 = AuthEntity(
        authId: '456',
        email: 'different@example.com',
        name: 'Different User',
        password: 'password456',
        confirmPassword: 'password456',
        profilePicture: 'different.jpg',
      );

      // Assert
      expect(entity1, equals(entity2));
      expect(entity1, isNot(equals(entity3)));
    });

    test('should handle props correctly', () {
      // Arrange
      const authEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        confirmPassword: 'password123',
        profilePicture: 'profile.jpg',
      );

      // Act
      final props = authEntity.props;

      // Assert
      expect(props.length, equals(6));
      expect(props[0], equals('123'));
      expect(props[1], equals('test@example.com'));
      expect(props[2], equals('Test User'));
      expect(props[3], equals('password123'));
      expect(props[4], equals('password123'));
      expect(props[5], equals('profile.jpg'));
    });

    test('should handle nullable properties', () {
      // Act
      const authEntity = AuthEntity(
        authId: null,
        email: 'test@example.com',
        name: 'Test User',
        password: null,
        confirmPassword: null,
        profilePicture: null,
      );

      // Assert
      expect(authEntity.authId, isNull);
      expect(authEntity.email, equals('test@example.com'));
      expect(authEntity.name, equals('Test User'));
      expect(authEntity.password, isNull);
      expect(authEntity.confirmPassword, isNull);
      expect(authEntity.profilePicture, isNull);
    });
  });

  group('AuthStatus Tests', () {
    test('should handle all enum values', () {
      // Test all enum values
      expect(AuthStatus.initial, isA<AuthStatus>());
      expect(AuthStatus.loading, isA<AuthStatus>());
      expect(AuthStatus.authenticated, isA<AuthStatus>());
      expect(AuthStatus.unauthenticated, isA<AuthStatus>());
      expect(AuthStatus.registered, isA<AuthStatus>());
      expect(AuthStatus.loaded, isA<AuthStatus>());
      expect(AuthStatus.error, isA<AuthStatus>());
    });

    test('should handle enum comparisons', () {
      expect(AuthStatus.initial, equals(AuthStatus.initial));
      expect(AuthStatus.initial, isNot(equals(AuthStatus.loading)));
      expect(AuthStatus.authenticated, isNot(equals(AuthStatus.unauthenticated)));
    });
  });

  group('AuthState with AuthEntity Integration Tests', () {
    test('should handle AuthState with AuthEntity correctly', () {
      // Arrange
      const authEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: null,
        confirmPassword: null,
        profilePicture: null,
      );

      const state = AuthState(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
        errorMessage: null,
        uploadPhotoName: 'photo.jpg',
      );

      // Assert
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.authEntity, equals(authEntity));
      expect(state.authEntity?.authId, equals('123'));
      expect(state.authEntity?.email, equals('test@example.com'));
      expect(state.authEntity?.name, equals('Test User'));
      expect(state.errorMessage, isNull);
      expect(state.uploadPhotoName, equals('photo.jpg'));
    });

    test('should handle copyWith with AuthEntity', () {
      // Arrange
      const originalEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Test User',
        password: null,
        confirmPassword: null,
        profilePicture: null,
      );

      const originalState = AuthState(
        status: AuthStatus.authenticated,
        authEntity: originalEntity,
        errorMessage: null,
        uploadPhotoName: null,
      );

      const updatedEntity = AuthEntity(
        authId: '123',
        email: 'test@example.com',
        name: 'Updated User',
        password: null,
        confirmPassword: null,
        profilePicture: 'new_profile.jpg',
      );

      // Act
      final updatedState = originalState.copyWith(
        authEntity: updatedEntity,
        uploadPhotoName: 'new_photo.jpg',
      );

      // Assert
      expect(updatedState.status, equals(AuthStatus.authenticated));
      expect(updatedState.authEntity, equals(updatedEntity));
      expect(updatedState.authEntity?.name, equals('Updated User'));
      expect(updatedState.authEntity?.profilePicture, equals('new_profile.jpg'));
      expect(updatedState.uploadPhotoName, equals('new_photo.jpg'));
    });
  });
}
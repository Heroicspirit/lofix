import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/core/services/storage/token_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('TokenService', () {
    late TokenService tokenService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      tokenService = TokenService(prefs: mockPrefs);
    });

    test('should save token successfully', () async {
      // Arrange
      const token = 'test_auth_token';
      when(() => mockPrefs.setString('auth_token', token)).thenAnswer((_) async => true);

      // Act
      await tokenService.saveToken(token);

      // Assert
      verify(() => mockPrefs.setString('auth_token', token)).called(1);
    });

    test('should get token successfully', () {
      // Arrange
      const token = 'test_auth_token';
      when(() => mockPrefs.getString('auth_token')).thenReturn(token);

      // Act
      final result = tokenService.getToken();

      // Assert
      expect(result, equals(token));
      verify(() => mockPrefs.getString('auth_token')).called(1);
    });

    test('should return null when no token is saved', () {
      // Arrange
      when(() => mockPrefs.getString('auth_token')).thenReturn(null);

      // Act
      final result = tokenService.getToken();

      // Assert
      expect(result, isNull);
      verify(() => mockPrefs.getString('auth_token')).called(1);
    });

    test('should remove token successfully', () async {
      // Arrange
      when(() => mockPrefs.remove('auth_token')).thenAnswer((_) async => true);

      // Act
      await tokenService.removeToken();

      // Assert
      verify(() => mockPrefs.remove('auth_token')).called(1);
    });

    test('should handle save token failure gracefully', () async {
      // Arrange
      const token = 'test_auth_token';
      when(() => mockPrefs.setString('auth_token', token)).thenAnswer((_) async => false);

      // Act & Assert - should not throw exception even if save fails
      await tokenService.saveToken(token);

      // Assert
      verify(() => mockPrefs.setString('auth_token', token)).called(1);
    });

    test('should handle remove token failure gracefully', () async {
      // Arrange
      when(() => mockPrefs.remove('auth_token')).thenAnswer((_) async => false);

      // Act & Assert - should not throw exception even if remove fails
      await tokenService.removeToken();

      // Assert
      verify(() => mockPrefs.remove('auth_token')).called(1);
    });
  });
}

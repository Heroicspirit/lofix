import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/core/services/storage/storage_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('StorageService', () {
    late StorageService storageService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      storageService = StorageService(prefs: mockPrefs);
    });

    group('String operations', () {
      test('should set string successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(() => mockPrefs.setString(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setString(key, value);

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.setString(key, value)).called(1);
      });

      test('should get string successfully', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(() => mockPrefs.getString(key)).thenReturn(value);

        // Act
        final result = storageService.getString(key);

        // Assert
        expect(result, equals(value));
        verify(() => mockPrefs.getString(key)).called(1);
      });

      test('should return null when string key does not exist', () {
        // Arrange
        const key = 'non_existent_key';
        when(() => mockPrefs.getString(key)).thenReturn(null);

        // Act
        final result = storageService.getString(key);

        // Assert
        expect(result, isNull);
        verify(() => mockPrefs.getString(key)).called(1);
      });
    });

    group('Int operations', () {
      test('should set int successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 42;
        when(() => mockPrefs.setInt(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setInt(key, value);

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.setInt(key, value)).called(1);
      });

      test('should get int successfully', () {
        // Arrange
        const key = 'test_key';
        const value = 42;
        when(() => mockPrefs.getInt(key)).thenReturn(value);

        // Act
        final result = storageService.getInt(key);

        // Assert
        expect(result, equals(value));
        verify(() => mockPrefs.getInt(key)).called(1);
      });
    });

    group('Bool operations', () {
      test('should set bool successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = true;
        when(() => mockPrefs.setBool(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setBool(key, value);

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.setBool(key, value)).called(1);
      });

      test('should get bool successfully', () {
        // Arrange
        const key = 'test_key';
        const value = true;
        when(() => mockPrefs.getBool(key)).thenReturn(value);

        // Act
        final result = storageService.getBool(key);

        // Assert
        expect(result, equals(value));
        verify(() => mockPrefs.getBool(key)).called(1);
      });
    });

    group('StringList operations', () {
      test('should set string list successfully', () async {
        // Arrange
        const key = 'test_key';
        final value = ['item1', 'item2', 'item3'];
        when(() => mockPrefs.setStringList(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setStringList(key, value);

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.setStringList(key, value)).called(1);
      });

      test('should get string list successfully', () {
        // Arrange
        const key = 'test_key';
        final value = ['item1', 'item2', 'item3'];
        when(() => mockPrefs.getStringList(key)).thenReturn(value);

        // Act
        final result = storageService.getStringList(key);

        // Assert
        expect(result, equals(value));
        verify(() => mockPrefs.getStringList(key)).called(1);
      });
    });

    group('Remove and Clear operations', () {
      test('should remove key successfully', () async {
        // Arrange
        const key = 'test_key';
        when(() => mockPrefs.remove(key)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.remove(key);

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.remove(key)).called(1);
      });

      test('should clear all data successfully', () async {
        // Arrange
        when(() => mockPrefs.clear()).thenAnswer((_) async => true);

        // Act
        final result = await storageService.clear();

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.clear()).called(1);
      });
    });

    group('ContainsKey operation', () {
      test('should return true when key exists', () {
        // Arrange
        const key = 'existing_key';
        when(() => mockPrefs.containsKey(key)).thenReturn(true);

        // Act
        final result = storageService.containsKey(key);

        // Assert
        expect(result, isTrue);
        verify(() => mockPrefs.containsKey(key)).called(1);
      });

      test('should return false when key does not exist', () {
        // Arrange
        const key = 'non_existent_key';
        when(() => mockPrefs.containsKey(key)).thenReturn(false);

        // Act
        final result = storageService.containsKey(key);

        // Assert
        expect(result, isFalse);
        verify(() => mockPrefs.containsKey(key)).called(1);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:musicapp/features/dashboard/presentation/view_model/favorites_viewmodel.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:musicapp/core/services/storage/favorites_storage_service.dart';
import 'package:musicapp/core/error/failures.dart';

class MockAddToFavoritesUseCase extends Mock implements AddToFavoritesUseCase {}
class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}
class MockRemoveFromFavoritesUseCase extends Mock implements RemoveFromFavoritesUseCase {}
class MockFavoritesStorageService extends Mock implements FavoritesStorageService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('FavoritesViewModel Tests', () {
    late FavoritesViewModel favoritesViewModel;
    late MockAddToFavoritesUseCase mockAddToFavoritesUseCase;
    late MockGetFavoritesUseCase mockGetFavoritesUseCase;
    late MockRemoveFromFavoritesUseCase mockRemoveFromFavoritesUseCase;
    late MockFavoritesStorageService mockFavoritesStorageService;
    late MockSharedPreferences mockSharedPreferences;
    late ProviderContainer container;

    setUp(() {
      mockAddToFavoritesUseCase = MockAddToFavoritesUseCase();
      mockGetFavoritesUseCase = MockGetFavoritesUseCase();
      mockRemoveFromFavoritesUseCase = MockRemoveFromFavoritesUseCase();
      mockFavoritesStorageService = MockFavoritesStorageService();
      mockSharedPreferences = MockSharedPreferences();

      // Setup fallback values for mocks
      registerFallbackValue(const Right(null));
      registerFallbackValue(const ApiFailure(message: 'Test failure'));

      container = ProviderContainer(
        overrides: [
          addToFavoritesUseCaseProvider.overrideWithValue(mockAddToFavoritesUseCase),
          getFavoritesUseCaseProvider.overrideWithValue(mockGetFavoritesUseCase),
          removeFromFavoritesUseCaseProvider.overrideWithValue(mockRemoveFromFavoritesUseCase),
          favoritesStorageServiceProvider.overrideWithValue(mockFavoritesStorageService),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );

      favoritesViewModel = container.read(favoritesProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with loading state', () {
      // Act
      final state = container.read(favoritesProvider);

      // Assert
      expect(state.isLoading, isTrue);
      expect(state.value, isNull);
      expect(state.error, isNull);
    });

    group('loadFavorites', () {
      test('should load favorites successfully', () async {
        // Arrange
        final favorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
          const MusicEntity(
            id: '2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ];

        when(() => mockGetFavoritesUseCase()).thenAnswer((_) async => Right(favorites));

        // Act
        await favoritesViewModel.loadFavorites();

        // Assert
        final state = container.read(favoritesProvider);
        expect(state.isLoading, isFalse);
        expect(state.value, equals(favorites));
        expect(state.error, isNull);
        verify(() => mockGetFavoritesUseCase()).called(1);
        // Verify local storage is updated
        verify(() => mockFavoritesStorageService.saveFavorites(['1', '2'])).called(1);
      });
    });

    group('addToFavorites', () {
      test('should add to favorites successfully', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        final updatedFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
          const MusicEntity(
            id: '2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ];

        // Set initial state
        favoritesViewModel.state = AsyncValue.data(initialFavorites);
        
        when(() => mockAddToFavoritesUseCase('2')).thenAnswer((_) async => const Right(null));
        when(() => mockGetFavoritesUseCase()).thenAnswer((_) async => Right(updatedFavorites));

        // Act
        await favoritesViewModel.addToFavorites('2');

        // Assert
        verify(() => mockAddToFavoritesUseCase('2')).called(1);
        verify(() => mockGetFavoritesUseCase()).called(1);
        // Verify local storage interactions
        verify(() => mockFavoritesStorageService.addToFavorites('2')).called(1);
      });

      test('should handle add to favorites failure', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        const failure = ApiFailure(message: 'Failed to add to favorites');

        // Set initial state
        favoritesViewModel.state = AsyncValue.data(initialFavorites);
        
        when(() => mockAddToFavoritesUseCase('2')).thenAnswer((_) async => Left(failure));

        // Act
        await favoritesViewModel.addToFavorites('2');

        // Assert
        final state = container.read(favoritesProvider);
        expect(state.value, equals(initialFavorites)); // Should revert to original state
        verify(() => mockAddToFavoritesUseCase('2')).called(1);
        verifyNever(() => mockGetFavoritesUseCase());
        // Verify local storage revert on failure
        verify(() => mockFavoritesStorageService.addToFavorites('2')).called(1);
        verify(() => mockFavoritesStorageService.removeFromFavorites('2')).called(1);
      });
    });

    group('removeFromFavorites', () {
      test('should remove from favorites successfully', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
          const MusicEntity(
            id: '2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ];

        final expectedFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        // Set initial state
        favoritesViewModel.state = AsyncValue.data(initialFavorites);
        
        when(() => mockRemoveFromFavoritesUseCase('2')).thenAnswer((_) async => const Right(null));

        // Act
        await favoritesViewModel.removeFromFavorites('2');

        // Assert
        final state = container.read(favoritesProvider);
        expect(state.value, equals(expectedFavorites));
        verify(() => mockRemoveFromFavoritesUseCase('2')).called(1);
      });

      test('should handle remove from favorites failure', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
          const MusicEntity(
            id: '2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ];

        const failure = ApiFailure(message: 'Failed to remove from favorites');

        // Set initial state
        favoritesViewModel.state = AsyncValue.data(initialFavorites);
        
        when(() => mockRemoveFromFavoritesUseCase('2')).thenAnswer((_) async => Left(failure));

        // Act
        await favoritesViewModel.removeFromFavorites('2');

        // Assert
        final state = container.read(favoritesProvider);
        expect(state.value, equals(initialFavorites)); // Should revert to original state
        verify(() => mockRemoveFromFavoritesUseCase('2')).called(1);
      });
    });

    group('isFavorite', () {
      test('should return true when song is in favorites', () {
        // Arrange
        final favorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
          const MusicEntity(
            id: '2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ];

        favoritesViewModel.state = AsyncValue.data(favorites);

        // Act
        final result = favoritesViewModel.isFavorite('1');

        // Assert
        expect(result, isTrue);
      });

      test('should return false when song is not in favorites', () {
        // Arrange
        final favorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        favoritesViewModel.state = AsyncValue.data(favorites);

        // Act
        final result = favoritesViewModel.isFavorite('3');

        // Assert
        expect(result, isFalse);
      });

      test('should return false when favorites list is empty', () {
        // Arrange
        favoritesViewModel.state = AsyncValue.data([]);

        // Act
        final result = favoritesViewModel.isFavorite('1');

        // Assert
        expect(result, isFalse);
      });

      test('should return false when state is null', () {
        // Arrange
        favoritesViewModel.state = const AsyncValue.data([]);

        // Act
        final result = favoritesViewModel.isFavorite('1');

        // Assert
        expect(result, isFalse);
      });

      test('should return false when state is loading', () {
        // Arrange
        favoritesViewModel.state = const AsyncValue.loading();

        // Act
        final result = favoritesViewModel.isFavorite('1');

        // Assert
        expect(result, isFalse);
      });

    group('state management', () {
      test('should add to favorites successfully', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        favoritesViewModel.state = AsyncValue.data(initialFavorites);
        
        when(() => mockAddToFavoritesUseCase('2')).thenAnswer((_) async => Right(null));
        when(() => mockGetFavoritesUseCase()).thenAnswer((_) async => Right(initialFavorites));

        // Act
        await favoritesViewModel.addToFavorites('2');

        // Assert
        verify(() => mockAddToFavoritesUseCase('2')).called(1);
        verify(() => mockFavoritesStorageService.addToFavorites('2')).called(1);
        verify(() => mockGetFavoritesUseCase()).called(1);
      });

      test('should handle optimistic updates correctly', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        favoritesViewModel.state = AsyncValue.data(initialFavorites);
        
        when(() => mockAddToFavoritesUseCase('2')).thenAnswer((_) async => Right(null));
        when(() => mockRemoveFromFavoritesUseCase('1')).thenAnswer((_) async => Right(null));
        when(() => mockGetFavoritesUseCase()).thenAnswer((_) async => Right([]));

        // Act
        await favoritesViewModel.addToFavorites('2');
        await favoritesViewModel.removeFromFavorites('1');

        // Assert
        verify(() => mockAddToFavoritesUseCase('2')).called(1);
        verify(() => mockRemoveFromFavoritesUseCase('1')).called(1);
      });

      test('should clear favorites successfully', () async {
        // Arrange
        final initialFavorites = [
          const MusicEntity(
            id: '1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/image1.jpg',
          ),
        ];

        favoritesViewModel.state = AsyncValue.data(initialFavorites);

        // Act
        await favoritesViewModel.clearFavorites();

        // Assert
        final state = container.read(favoritesProvider);
        expect(state.value, isEmpty);
        verify(() => mockFavoritesStorageService.clearFavorites()).called(1);
      });
    });
  });
});
}

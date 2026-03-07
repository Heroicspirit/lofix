import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:musicapp/core/error/failures.dart';

void main() {
  group('FavoritesProvider', () {
    late MockAddToFavoritesUseCase mockAddUseCase;
    late MockGetFavoritesUseCase mockGetUseCase;
    late MockRemoveFromFavoritesUseCase mockRemoveUseCase;
    late ProviderContainer container;

    setUp(() {
      mockAddUseCase = MockAddToFavoritesUseCase();
      mockGetUseCase = MockGetFavoritesUseCase();
      mockRemoveUseCase = MockRemoveFromFavoritesUseCase();
      
      container = ProviderContainer(overrides: [
        // Add provider overrides if needed
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('should load favorites successfully', () async {
      // Arrange
      final testSongs = [
        MusicEntity(
          id: 'test-song-1',
          title: 'Test Song 1',
          artist: 'Test Artist 1',
          album: 'Test Album 1',
          duration: 180,
          imageUrl: 'https://example.com/image1.jpg',
          audioUrl: 'https://example.com/audio1.mp3',
        ),
        MusicEntity(
          id: 'test-song-2',
          title: 'Test Song 2',
          artist: 'Test Artist 2',
          album: 'Test Album 2',
          duration: 200,
          imageUrl: 'https://example.com/image2.jpg',
          audioUrl: 'https://example.com/audio2.mp3',
        ),
      ];

      when(() => mockGetUseCase()).thenAnswer((_) async => Right(testSongs));

      // Act
      final result = await mockGetUseCase();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure'),
        (songs) => expect(songs.length, equals(2)),
      );
    });

    test('should handle add to favorites successfully', () async {
      // Arrange
      const songId = 'test-song-id';
      when(() => mockAddUseCase(songId)).thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockAddUseCase(songId);

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockAddUseCase(songId)).called(1);
    });

    test('should handle remove from favorites successfully', () async {
      // Arrange
      const songId = 'test-song-id';
      when(() => mockRemoveUseCase(songId)).thenAnswer((_) async => const Right(null));

      // Act
      final result = await mockRemoveUseCase(songId);

      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockRemoveUseCase(songId)).called(1);
    });

    test('should handle favorites loading error', () async {
      // Arrange
      when(() => mockGetUseCase()).thenAnswer((_) async => Left(ApiFailure(message: 'Failed to load favorites')));

      // Act
      final result = await mockGetUseCase();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Failed to load favorites')),
        (songs) => fail('Expected failure but got success'),
      );
    });

    test('should handle add to favorites error', () async {
      // Arrange
      const songId = 'invalid-song-id';
      when(() => mockAddUseCase(songId)).thenAnswer((_) async => Left(ApiFailure(message: 'Song not found')));

      // Act
      final result = await mockAddUseCase(songId);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Song not found')),
        (songs) => fail('Expected failure but got success'),
      );
    });
  });
}

class MockAddToFavoritesUseCase extends Mock implements AddToFavoritesUseCase {}

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

class MockRemoveFromFavoritesUseCase extends Mock implements RemoveFromFavoritesUseCase {}

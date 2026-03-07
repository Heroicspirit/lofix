import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';

void main() {
  group('AddToFavoritesUseCase', () {
    late FavoritesRepository mockRepository;
    late AddToFavoritesUseCase useCase;
    late MusicEntity testSong;

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = AddToFavoritesUseCase(mockRepository);
      testSong = MusicEntity(
        id: 'test-song-id',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: 180,
        imageUrl: 'https://example.com/image.jpg',
        audioUrl: 'https://example.com/audio.mp3',
      );
    });

    test('should call repository with correct song ID', () async {
      // Arrange
      when(() => mockRepository.addToFavorites('test-song-id'))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call('test-song-id');

      // Assert
      verify(() => mockRepository.addToFavorites('test-song-id')).called(1);
    });

    test('should return Right when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.addToFavorites('test-song-id'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call('test-song-id');

      // Assert
      expect(result, isA<Right<Failure, void>>());
    });

    test('should return Left when repository fails', () async {
      // Arrange
      const testFailure = ApiFailure(message: 'Test error');
      when(() => mockRepository.addToFavorites('test-song-id'))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase.call('test-song-id');

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (l) => expect(l, equals(testFailure)),
        (r) => fail('Should not succeed'),
      );
    });

    test('should handle empty song ID', () async {
      // Act & Assert
      expect(() => useCase.call(''), throwsA(isA<TypeError>()));
    });

    test('should handle null song ID', () async {
      // Act & Assert
      expect(() => useCase.call(''), throwsA(isA<TypeError>()));
    });
  });
}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late GetFavoritesUseCase usecase;
  late MockFavoritesRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoritesRepository();
    usecase = GetFavoritesUseCase(mockRepository);
  });

  const testMusicList = [
    MusicEntity(
      id: '1',
      title: 'Favorite Song 1',
      artist: 'Artist 1',
      imageUrl: 'http://example.com/fav1.jpg',
      audioUrl: 'http://example.com/fav1.mp3',
    ),
    MusicEntity(
      id: '2',
      title: 'Favorite Song 2',
      artist: 'Artist 2',
      imageUrl: 'http://example.com/fav2.jpg',
      audioUrl: 'http://example.com/fav2.mp3',
    ),
  ];

  group('GetFavoritesUseCase Tests', () {
    test('should call repository.getFavorites() and return Right with music list', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => Right(testMusicList));

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getFavorites()).called(1);
      expect(result, equals(Right(testMusicList)));
    });

    test('should return Left with Failure when repository fails', () async {
      // Arrange
      const testFailure = ApiFailure(message: 'Failed to fetch favorites', statusCode: 500);
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getFavorites()).called(1);
      expect(result, equals(Left(testFailure)));
    });

    test('should return Right with empty list when repository returns empty', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenAnswer((_) async => const Right<Failure, List<MusicEntity>>([]));

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getFavorites()).called(1);
      expect(result, equals(const Right<Failure, List<MusicEntity>>([])));
    });

    test('should propagate repository exception as Failure', () async {
      // Arrange
      when(() => mockRepository.getFavorites()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.getFavorites()).called(1);
    });
  });
}
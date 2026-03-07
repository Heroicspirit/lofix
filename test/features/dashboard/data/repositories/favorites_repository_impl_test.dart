import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:musicapp/features/dashboard/data/repositories/favorites_repository_impl.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

void main() {
  group('FavoritesRepositoryImpl', () {
    late FavoritesRepositoryImpl repository;
    late FavoritesRemoteDataSource mockDataSource;
    late ApiClient mockApiClient;

    setUp(() {
      mockDataSource = MockFavoritesRemoteDataSource();
      mockApiClient = MockApiClient();
      repository = FavoritesRepositoryImpl(mockDataSource);
    });

    group('addToFavorites', () {
      test('should call dataSource addToFavorites with correct song ID', () async {
        // Arrange
        when(() => mockDataSource.addToFavorites('test-song-id'))
            .thenAnswer((_) async => const Right(null));

        // Act
        await repository.addToFavorites('test-song-id');

        // Assert
        verify(() => mockDataSource.addToFavorites('test-song-id')).called(1);
      });

      test('should return Right when dataSource succeeds', () async {
        // Arrange
        when(() => mockDataSource.addToFavorites('test-song-id'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.addToFavorites('test-song-id');

        // Assert
        expect(result, isA<Right<Failure, void>>());
      });

      test('should return Left when dataSource fails', () async {
        // Arrange
        const testFailure = ApiFailure(message: 'Network error');
        when(() => mockDataSource.addToFavorites('test-song-id'))
            .thenAnswer((_) async => const Left(testFailure));

        // Act
        final result = await repository.addToFavorites('test-song-id');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (l) => expect(l, equals(testFailure)),
          (r) => fail('Should not succeed'),
        );
      });
    });

    group('getFavorites', () {
      test('should call dataSource getFavorites', () async {
        // Arrange
        final testSongs = [
          MusicEntity(
            id: 'song-1',
            title: 'Test Song',
            artist: 'Test Artist',
            album: 'Test Album',
            duration: 180,
            imageUrl: 'https://example.com/image.jpg',
            audioUrl: 'https://example.com/audio.mp3',
            releaseDate: null,
          ),
        ];
        when(() => mockDataSource.getFavorites())
            .thenAnswer((_) async => Right(testSongs));

        // Act
        await repository.getFavorites();

        // Assert
        verify(() => mockDataSource.getFavorites()).called(1);
      });

      test('should return Right with songs when dataSource succeeds', () async {
        // Arrange
        final testSongs = [
          MusicEntity(
            id: 'song-1',
            title: 'Test Song',
            artist: 'Test Artist',
            album: 'Test Album',
            duration: 180,
            imageUrl: 'https://example.com/image.jpg',
            audioUrl: 'https://example.com/audio.mp3',
            releaseDate: null,
          ),
        ];
        when(() => mockDataSource.getFavorites())
            .thenAnswer((_) async => Right(testSongs));

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, isA<Right<Failure, List<MusicEntity>>>());
        final songs = result.fold((l) => [], (r) => r);
        expect(songs, hasLength(1));
        expect(songs[0].title, equals('Test Song'));
      });

      test('should return Left when dataSource fails', () async {
        // Arrange
        const testFailure = ApiFailure(message: 'Network error');
        when(() => mockDataSource.getFavorites())
            .thenAnswer((_) async => const Left(testFailure));

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, isA<Left<Failure, List<MusicEntity>>>());
        result.fold(
          (l) => expect(l, equals(testFailure)),
          (r) => fail('Should not succeed'),
        );
      });
    });

    group('removeFromFavorites', () {
      test('should call dataSource removeFromFavorites with correct song ID', () async {
        // Arrange
        when(() => mockDataSource.removeFromFavorites('test-song-id'))
            .thenAnswer((_) async => const Right(null));

        // Act
        await repository.removeFromFavorites('test-song-id');

        // Assert
        verify(() => mockDataSource.removeFromFavorites('test-song-id')).called(1);
      });

      test('should return Right when dataSource succeeds', () async {
        // Arrange
        when(() => mockDataSource.removeFromFavorites('test-song-id'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.removeFromFavorites('test-song-id');

        // Assert
        expect(result, isA<Right<Failure, void>>());
      });

      test('should return Left when dataSource fails', () async {
        // Arrange
        const testFailure = ApiFailure(message: 'Network error');
        when(() => mockDataSource.removeFromFavorites('test-song-id'))
            .thenAnswer((_) async => const Left(testFailure));

        // Act
        final result = await repository.removeFromFavorites('test-song-id');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (l) => expect(l, equals(testFailure)),
          (r) => fail('Should not succeed'),
        );
      });
    });
  });
}

class MockFavoritesRemoteDataSource extends Mock implements FavoritesRemoteDataSource {}
class MockApiClient extends Mock implements ApiClient {}

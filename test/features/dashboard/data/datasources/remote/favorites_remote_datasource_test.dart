import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

void main() {
  group('FavoritesRemoteDataSource', () {
    late FavoritesRemoteDataSource dataSource;
    late ApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = FavoritesRemoteDataSource(mockApiClient);
    });

    group('addToFavorites', () {
      test('should call apiClient post with correct endpoint and data', () async {
        // Arrange
        when(() => mockApiClient.post('/songs/favorites', data: {'songId': 'test-song-id'}))
            .thenAnswer((_) async => createSuccessResponse('/songs/favorites', {'success': true, 'message': 'Song added to favorites'}));

        // Act
        await dataSource.addToFavorites('test-song-id');

        // Assert
        verify(() => mockApiClient.post('/songs/favorites', data: {'songId': 'test-song-id'})).called(1);
      });

      test('should return Right when apiClient succeeds', () async {
        // Arrange
        when(() => mockApiClient.post('/songs/favorites', data: {'songId': 'test-song-id'}))
            .thenAnswer((_) async => createSuccessResponse('/songs/favorites', {'success': true, 'message': 'Song added to favorites'}));

        // Act
        final result = await dataSource.addToFavorites('test-song-id');

        // Assert
        expect(result, isA<Right<Failure, void>>());
      });

      test('should return Left when apiClient fails', () async {
        // Arrange
        when(() => mockApiClient.post('/songs/favorites', data: {'songId': 'test-song-id'}))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.addToFavorites('test-song-id');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (l) => expect(l, isA<ApiFailure>()),
          (r) => fail('Should not succeed'),
        );
      });
    });

    group('getFavorites', () {
      test('should call apiClient get with correct endpoint', () async {
        // Arrange
        when(() => mockApiClient.get('/songs/favorites'))
            .thenAnswer((_) async => createSuccessResponse('/songs/favorites', {
              'success': true,
              'data': [
                {
                  '_id': 'song-1',
                  'title': 'Test Song',
                  'artist': {'name': 'Test Artist'},
                  'imageUrl': 'https://example.com/image.jpg',
                  'duration': 180,
                }
              ]
            }));

        // Act
        await dataSource.getFavorites();

        // Assert
        verify(() => mockApiClient.get('/songs/favorites')).called(1);
      });

      test('should return Right with songs when apiClient succeeds', () async {
        // Arrange
        when(() => mockApiClient.get('/songs/favorites'))
            .thenAnswer((_) async => createSuccessResponse('/songs/favorites', {
              'success': true,
              'data': [
                {
                  '_id': 'song-1',
                  'title': 'Test Song',
                  'artist': {'name': 'Test Artist'},
                  'imageUrl': 'https://example.com/image.jpg',
                  'duration': 180,
                }
              ]
            }));

        // Act
        final result = await dataSource.getFavorites();

        // Assert
        expect(result, isA<Right<Failure, List<MusicEntity>>>());
        final songs = result.fold((l) => [], (r) => r);
        expect(songs, hasLength(1));
        expect(songs[0].title, equals('Test Song'));
        expect(songs[0].artist, equals('Test Artist'));
      });

      test('should return Left when apiClient fails', () async {
        // Arrange
        when(() => mockApiClient.get('/songs/favorites'))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getFavorites();

        // Assert
        expect(result, isA<Left<Failure, List<MusicEntity>>>());
        expect(result.fold((l) => l, (r) => r), isA<ApiFailure>());
      });
    });

    group('removeFromFavorites', () {
      test('should call apiClient delete with correct endpoint', () async {
        // Arrange
        when(() => mockApiClient.delete('/songs/favorites/test-song-id'))
            .thenAnswer((_) async => createSuccessResponse('/songs/favorites/test-song-id', {'success': true, 'message': 'Song removed from favorites'}));

        // Act
        await dataSource.removeFromFavorites('test-song-id');

        // Assert
        verify(() => mockApiClient.delete('/songs/favorites/test-song-id')).called(1);
      });

      test('should return Right when apiClient succeeds', () async {
        // Arrange
        when(() => mockApiClient.delete('/songs/favorites/test-song-id'))
            .thenAnswer((_) async => createSuccessResponse('/songs/favorites/test-song-id', {'success': true, 'message': 'Song removed from favorites'}));

        // Act
        final result = await dataSource.removeFromFavorites('test-song-id');

        // Assert
        expect(result, isA<Right<Failure, void>>());
      });

      test('should return Left when apiClient fails', () async {
        // Arrange
        when(() => mockApiClient.delete('/songs/favorites/test-song-id'))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.removeFromFavorites('test-song-id');

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (l) => expect(l, isA<ApiFailure>()),
          (r) => fail('Should not succeed'),
        );
      });
    });
  });
}

class MockApiClient extends Mock implements ApiClient {}

Response createSuccessResponse(String path, dynamic data) {
  return Response(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );
}

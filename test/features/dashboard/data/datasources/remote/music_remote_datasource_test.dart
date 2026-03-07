import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/music_remote_datasource.dart';
import 'package:musicapp/features/dashboard/data/models/music_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('MusicRemoteDataSource', () {
    late MusicRemoteDataSourceImpl dataSource;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = MusicRemoteDataSourceImpl(mockApiClient);
    });

    group('getTopPicks', () {
      test('should return list of MusicModel when API call succeeds', () async {
        // Arrange
        final mockResponse = createSuccessResponse([
          {
            '_id': 'song-1',
            'title': 'Test Song 1',
            'artist': {'name': 'Test Artist 1'},
            'imageUrl': 'https://example.com/image1.jpg',
            'duration': 180,
          },
          {
            '_id': 'song-2',
            'title': 'Test Song 2',
            'artist': {'name': 'Test Artist 2'},
            'imageUrl': 'https://example.com/image2.jpg',
            'duration': 200,
          }
        ]);
        
        when(() => mockApiClient.get('songs')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getTopPicks();

        // Assert
        expect(result, isA<List<MusicModel>>());
        expect(result, hasLength(2));
        expect(result[0].title, equals('Test Song 1'));
        expect(result[1].title, equals('Test Song 2'));
        verify(() => mockApiClient.get('songs')).called(1);
      });

      test('should throw exception when API call fails with non-200 status', () async {
        // Arrange
        final mockResponse = createErrorResponse(404);
        when(() => mockApiClient.get('songs')).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(() async => await dataSource.getTopPicks(), throwsException);
        verify(() => mockApiClient.get('songs')).called(1);
      });

      test('should throw exception when API call throws error', () async {
        // Arrange
        when(() => mockApiClient.get('songs')).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() async => await dataSource.getTopPicks(), throwsException);
        verify(() => mockApiClient.get('songs')).called(1);
      });
    });

    group('getNewReleases', () {
      test('should return list of MusicModel when API call succeeds', () async {
        // Arrange
        final mockResponse = createSuccessResponse([
          {
            '_id': 'new-song-1',
            'title': 'New Release 1',
            'artist': {'name': 'New Artist 1'},
            'imageUrl': 'https://example.com/new1.jpg',
            'duration': 210,
          }
        ]);
        
        when(() => mockApiClient.get('songs')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getNewReleases();

        // Assert
        expect(result, isA<List<MusicModel>>());
        expect(result, hasLength(1));
        expect(result[0].title, equals('New Release 1'));
        verify(() => mockApiClient.get('songs')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockApiClient.get('songs')).thenThrow(Exception('Server error'));

        // Act & Assert
        expect(() async => await dataSource.getNewReleases(), throwsException);
        verify(() => mockApiClient.get('songs')).called(1);
      });
    });

    group('getTrending', () {
      test('should return list of MusicModel when API call succeeds', () async {
        // Arrange
        final mockResponse = createSuccessResponse([
          {
            '_id': 'trending-1',
            'title': 'Trending Song 1',
            'artist': {'name': 'Trending Artist 1'},
            'imageUrl': 'https://example.com/trending1.jpg',
            'duration': 195,
          }
        ]);
        
        when(() => mockApiClient.get('songs')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getTrending();

        // Assert
        expect(result, isA<List<MusicModel>>());
        expect(result, hasLength(1));
        expect(result[0].title, equals('Trending Song 1'));
        verify(() => mockApiClient.get('songs')).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockApiClient.get('songs')).thenThrow(Exception('Connection error'));

        // Act & Assert
        expect(() async => await dataSource.getTrending(), throwsException);
        verify(() => mockApiClient.get('songs')).called(1);
      });
    });

    group('searchSongs', () {
      test('should return list of MusicModel when search succeeds', () async {
        // Arrange
        const query = 'test query';
        final mockResponse = createSuccessResponse([
          {
            '_id': 'search-1',
            'title': 'Search Result 1',
            'artist': {'name': 'Search Artist 1'},
            'imageUrl': 'https://example.com/search1.jpg',
            'duration': 220,
          }
        ]);
        
        when(() => mockApiClient.get('songs?q=$query')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.searchSongs(query);

        // Assert
        expect(result, isA<List<MusicModel>>());
        expect(result, hasLength(1));
        expect(result[0].title, equals('Search Result 1'));
        verify(() => mockApiClient.get('songs?q=$query')).called(1);
      });

      test('should throw exception when search API call fails', () async {
        // Arrange
        const query = 'test query';
        when(() => mockApiClient.get('songs?q=$query')).thenThrow(Exception('Search failed'));

        // Act & Assert
        expect(() async => await dataSource.searchSongs(query), throwsException);
        verify(() => mockApiClient.get('songs?q=$query')).called(1);
      });

      test('should handle empty search results', () async {
        // Arrange
        const query = 'empty query';
        final mockResponse = createSuccessResponse([]);
        when(() => mockApiClient.get('songs?q=$query')).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.searchSongs(query);

        // Assert
        expect(result, isA<List<MusicModel>>());
        expect(result, isEmpty);
        verify(() => mockApiClient.get('songs?q=$query')).called(1);
      });
    });
  });
}

Response createSuccessResponse(List<dynamic> data) {
  return Response(
    requestOptions: RequestOptions(path: '/songs'),
    statusCode: 200,
    data: {
      'success': true,
      'data': data,
    },
  );
}

Response createErrorResponse(int statusCode) {
  return Response(
    requestOptions: RequestOptions(path: '/songs'),
    statusCode: statusCode,
    data: {'error': 'Failed to load songs'},
  );
}

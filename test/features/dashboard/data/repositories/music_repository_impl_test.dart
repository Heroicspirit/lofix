import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/music_remote_datasource.dart';
import 'package:musicapp/features/dashboard/data/repositories/music_repository_impl.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/data/models/music_model.dart';

class MockMusicRemoteDataSource extends Mock implements MusicRemoteDataSource {}

void main() {
  group('MusicRepositoryImpl', () {
    late MusicRepositoryImpl repository;
    late MockMusicRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockMusicRemoteDataSource();
      repository = MusicRepositoryImpl(mockDataSource);
    });

    group('getTopPicks', () {
      test('should return list of MusicEntity when data source succeeds', () async {
        // Arrange
        final testSongs = [
          const MusicModel(
            id: 'song-1',
            title: 'Test Song 1',
            artist: 'Test Artist 1',
            album: 'Test Album 1',
            duration: 180,
            imageUrl: 'https://example.com/image1.jpg',
            audioUrl: 'https://example.com/audio1.mp3',
          ),
          const MusicModel(
            id: 'song-2',
            title: 'Test Song 2',
            artist: 'Test Artist 2',
            album: 'Test Album 2',
            duration: 200,
            imageUrl: 'https://example.com/image2.jpg',
            audioUrl: 'https://example.com/audio2.mp3',
          ),
        ];
        
        when(() => mockDataSource.getTopPicks()).thenAnswer((_) async => testSongs);

        // Act
        final result = await repository.getTopPicks();

        // Assert
        expect(result, isA<List<MusicEntity>>());
        expect(result, hasLength(2));
        expect(result[0].title, equals('Test Song 1'));
        expect(result[1].title, equals('Test Song 2'));
        verify(() => mockDataSource.getTopPicks()).called(1);
      });

      test('should return empty list when data source returns empty list', () async {
        // Arrange
        when(() => mockDataSource.getTopPicks()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getTopPicks();

        // Assert
        expect(result, isEmpty);
        verify(() => mockDataSource.getTopPicks()).called(1);
      });

      test('should propagate exception when data source throws', () async {
        // Arrange
        when(() => mockDataSource.getTopPicks()).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() async => await repository.getTopPicks(), throwsException);
        verify(() => mockDataSource.getTopPicks()).called(1);
      });
    });

    group('getNewReleases', () {
      test('should return list of MusicEntity when data source succeeds', () async {
        // Arrange
        final testSongs = [
          const MusicModel(
            id: 'new-1',
            title: 'New Release 1',
            artist: 'New Artist 1',
            album: 'New Album 1',
            duration: 210,
            imageUrl: 'https://example.com/new1.jpg',
            audioUrl: 'https://example.com/new1.mp3',
          ),
        ];
        
        when(() => mockDataSource.getNewReleases()).thenAnswer((_) async => testSongs);

        // Act
        final result = await repository.getNewReleases();

        // Assert
        expect(result, isA<List<MusicEntity>>());
        expect(result, hasLength(1));
        expect(result[0].title, equals('New Release 1'));
        verify(() => mockDataSource.getNewReleases()).called(1);
      });

      test('should propagate exception when data source throws', () async {
        // Arrange
        when(() => mockDataSource.getNewReleases()).thenThrow(Exception('Server error'));

        // Act & Assert
        expect(() async => await repository.getNewReleases(), throwsException);
        verify(() => mockDataSource.getNewReleases()).called(1);
      });
    });

    group('getTrending', () {
      test('should return list of MusicEntity when data source succeeds', () async {
        // Arrange
        final testSongs = [
          const MusicModel(
            id: 'trending-1',
            title: 'Trending Song 1',
            artist: 'Trending Artist 1',
            album: 'Trending Album 1',
            duration: 195,
            imageUrl: 'https://example.com/trending1.jpg',
            audioUrl: 'https://example.com/trending1.mp3',
          ),
        ];
        
        when(() => mockDataSource.getTrending()).thenAnswer((_) async => testSongs);

        // Act
        final result = await repository.getTrending();

        // Assert
        expect(result, isA<List<MusicEntity>>());
        expect(result, hasLength(1));
        expect(result[0].title, equals('Trending Song 1'));
        verify(() => mockDataSource.getTrending()).called(1);
      });

      test('should propagate exception when data source throws', () async {
        // Arrange
        when(() => mockDataSource.getTrending()).thenThrow(Exception('Connection error'));

        // Act & Assert
        expect(() async => await repository.getTrending(), throwsException);
        verify(() => mockDataSource.getTrending()).called(1);
      });
    });

    group('searchSongs', () {
      test('should return list of MusicEntity when data source succeeds', () async {
        // Arrange
        const query = 'test query';
        final testSongs = [
          const MusicModel(
            id: 'search-1',
            title: 'Search Result 1',
            artist: 'Search Artist 1',
            album: 'Search Album 1',
            duration: 220,
            imageUrl: 'https://example.com/search1.jpg',
            audioUrl: 'https://example.com/search1.mp3',
          ),
        ];
        
        when(() => mockDataSource.searchSongs(query)).thenAnswer((_) async => testSongs);

        // Act
        final result = await repository.searchSongs(query);

        // Assert
        expect(result, isA<List<MusicEntity>>());
        expect(result, hasLength(1));
        expect(result[0].title, equals('Search Result 1'));
        verify(() => mockDataSource.searchSongs(query)).called(1);
      });

      test('should return empty list when no search results found', () async {
        // Arrange
        const query = 'no results';
        when(() => mockDataSource.searchSongs(query)).thenAnswer((_) async => []);

        // Act
        final result = await repository.searchSongs(query);

        // Assert
        expect(result, isEmpty);
        verify(() => mockDataSource.searchSongs(query)).called(1);
      });

      test('should propagate exception when data source throws', () async {
        // Arrange
        const query = 'error query';
        when(() => mockDataSource.searchSongs(query)).thenThrow(Exception('Search failed'));

        // Act & Assert
        expect(() async => await repository.searchSongs(query), throwsException);
        verify(() => mockDataSource.searchSongs(query)).called(1);
      });
    });
  });
}

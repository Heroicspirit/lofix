import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/repositories/music_repository.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_new_releases_usecase.dart';

class MockMusicRepository extends Mock implements MusicRepository {}

void main() {
  late GetNewReleasesUseCase usecase;
  late MockMusicRepository mockRepository;

  setUp(() {
    mockRepository = MockMusicRepository();
    usecase = GetNewReleasesUseCase(mockRepository);
  });

  const testMusicList = [
    MusicEntity(
      id: '1',
      title: 'New Release 1',
      artist: 'Artist 1',
      imageUrl: 'http://example.com/new1.jpg',
      audioUrl: 'http://example.com/new1.mp3',
    ),
    MusicEntity(
      id: '2',
      title: 'New Release 2',
      artist: 'Artist 2',
      imageUrl: 'http://example.com/new2.jpg',
      audioUrl: 'http://example.com/new2.mp3',
    ),
  ];

  group('GetNewReleasesUseCase Tests', () {
    test('should call repository.getNewReleases() and return music list', () async {
      // Arrange
      when(() => mockRepository.getNewReleases()).thenAnswer((_) async => testMusicList);

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getNewReleases()).called(1);
      expect(result, equals(testMusicList));
    });

    test('should return empty list when repository returns empty', () async {
      // Arrange
      when(() => mockRepository.getNewReleases()).thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getNewReleases()).called(1);
      expect(result, isEmpty);
    });

    test('should propagate repository exception', () async {
      // Arrange
      const errorMessage = 'Failed to fetch new releases';
      when(() => mockRepository.getNewReleases()).thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.getNewReleases()).called(1);
    });
  });
}
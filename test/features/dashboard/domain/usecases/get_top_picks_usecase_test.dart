import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/repositories/music_repository.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_top_picks_usecase.dart';

class MockMusicRepository extends Mock implements MusicRepository {}

void main() {
  late GetTopPicksUseCase usecase;
  late MockMusicRepository mockRepository;

  setUp(() {
    mockRepository = MockMusicRepository();
    usecase = GetTopPicksUseCase(mockRepository);
  });

  const testMusicList = [
    MusicEntity(
      id: '1',
      title: 'Test Song 1',
      artist: 'Test Artist 1',
      imageUrl: 'http://example.com/image1.jpg',
      audioUrl: 'http://example.com/audio1.mp3',
    ),
    MusicEntity(
      id: '2',
      title: 'Test Song 2',
      artist: 'Test Artist 2',
      imageUrl: 'http://example.com/image2.jpg',
      audioUrl: 'http://example.com/audio2.mp3',
    ),
  ];

  group('GetTopPicksUseCase Tests', () {
    test('should call repository.getTopPicks() and return music list', () async {
      // Arrange
      when(() => mockRepository.getTopPicks()).thenAnswer((_) async => testMusicList);

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getTopPicks()).called(1);
      expect(result, equals(testMusicList));
    });

    test('should return empty list when repository returns empty', () async {
      // Arrange
      when(() => mockRepository.getTopPicks()).thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      verify(() => mockRepository.getTopPicks()).called(1);
      expect(result, isEmpty);
    });

    test('should propagate repository exception', () async {
      // Arrange
      const errorMessage = 'Failed to fetch top picks';
      when(() => mockRepository.getTopPicks()).thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.getTopPicks()).called(1);
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/audio/music_player_service.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockStateController<T> extends Mock implements StateController<T> {
  T _state = _defaultValue<T>();

  static T _defaultValue<T>() {
    if (T == bool) return false as T;
    if (T == int) return 0 as T;
    if (T == double) return 0.0 as T;
    if (T == String) return '' as T;
    return null as T;
  }

  @override
  T get state => _state;

  @override
  set state(T value) => _state = value;
}

void main() {
  setUpAll(() {
    registerFallbackValue(UrlSource(''));
    registerFallbackValue(PlayerMode.mediaPlayer);
    registerFallbackValue(MusicEntity(
      id: 'fallback',
      title: 'Fallback',
      artist: 'Fallback',
      imageUrl: 'https://example.com/fallback.jpg',
    ));
  });

  group('MusicPlayerService', () {
    late MusicPlayerService musicPlayerService;
    late MockAudioPlayer mockAudioPlayer;
    late MockStateController<MusicEntity?> mockCurrentSongController;
    late MockStateController<bool> mockIsPlayingController;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      mockCurrentSongController = MockStateController<MusicEntity?>();
      mockIsPlayingController = MockStateController<bool>();
      
      musicPlayerService = MusicPlayerService(
        audioPlayer: mockAudioPlayer,
        currentSongController: mockCurrentSongController,
        isPlayingController: mockIsPlayingController,
        songList: [],
      );
    });

    test('should initialize with correct dependencies', () {
      // Assert - the service should be properly initialized
      expect(musicPlayerService, isA<MusicPlayerService>());
    });

    test('should play song correctly', () async {
      // Arrange
      final testSong = MusicEntity(
        id: 'test-song-id',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: 180,
        imageUrl: 'https://example.com/image.jpg',
        audioUrl: 'https://example.com/audio.mp3',
      );

      when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
      when(() => mockAudioPlayer.setVolume(any())).thenAnswer((_) async {});
      when(() => mockAudioPlayer.setPlayerMode(any())).thenAnswer((_) async {});
      when(() => mockAudioPlayer.play(any())).thenAnswer((_) async {});

      // Act
      await musicPlayerService.playSong(testSong);

      // Assert
      verify(() => mockAudioPlayer.stop()).called(1);
      verify(() => mockAudioPlayer.setVolume(1.0)).called(1);
      verify(() => mockAudioPlayer.setPlayerMode(PlayerMode.mediaPlayer)).called(1);
      verify(() => mockAudioPlayer.play(any())).called(1);
    });

    test('should pause playback correctly', () async {
      // Arrange
      when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});

      // Act
      await musicPlayerService.pauseSong();

      // Assert
      verify(() => mockAudioPlayer.pause()).called(1);
    });

    test('should resume playback correctly', () async {
      // Arrange
      when(() => mockAudioPlayer.resume()).thenAnswer((_) async {});

      // Act
      await musicPlayerService.resumeSong();

      // Assert
      verify(() => mockAudioPlayer.resume()).called(1);
    });
  });
}

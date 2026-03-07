import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/services/audio/music_player_service.dart';
import 'package:musicapp/core/services/audio/music_player_provider.dart';

void main() {
  group('MusicPlayerProvider', () {
    late MusicPlayerService mockMusicPlayerService;
    late ProviderContainer container;

    setUp(() {
      mockMusicPlayerService = MockMusicPlayerService();
      container = ProviderContainer(overrides: [
        musicPlayerServiceProvider.overrideWithValue(mockMusicPlayerService),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('should provide MusicPlayerService instance', () {
      // Act
      final musicPlayerService = container.read(musicPlayerServiceProvider);

      // Assert
      expect(musicPlayerService, isA<MusicPlayerService>());
    });

    test('should provide same instance across multiple reads', () {
      // Act
      final service1 = container.read(musicPlayerServiceProvider);
      final service2 = container.read(musicPlayerServiceProvider);

      // Assert
      expect(identical(service1, service2), isTrue);
    });
  });
}

class MockMusicPlayerService extends Mock implements MusicPlayerService {}

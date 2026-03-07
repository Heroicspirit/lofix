import 'package:flutter_test/flutter_test.dart';

import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

void main() {
  group('PlaylistEntity Tests', () {
    test('should create PlaylistEntity correctly', () {
      // Act
      final playlist = PlaylistEntity(
        id: '1',
        name: 'My Playlist',
        description: 'My Description',
        coverImage: 'https://example.com/cover.jpg',
        songs: const [
          MusicEntity(
            id: 'song1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/song1.jpg',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist.id, equals('1'));
      expect(playlist.name, equals('My Playlist'));
      expect(playlist.description, equals('My Description'));
      expect(playlist.coverImage, equals('https://example.com/cover.jpg'));
      expect(playlist.songs.length, equals(1));
      expect(playlist.songs.first.id, equals('song1'));
      expect(playlist.createdAt, isNotNull);
      expect(playlist.updatedAt, isNotNull);
    });

    test('should create PlaylistEntity with minimal required fields', () {
      // Act
      final playlist = PlaylistEntity(
        id: '1',
        name: 'Minimal Playlist',
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist.id, equals('1'));
      expect(playlist.name, equals('Minimal Playlist'));
      expect(playlist.description, isNull);
      expect(playlist.coverImage, isNull);
      expect(playlist.songs, isEmpty);
      expect(playlist.createdAt, isNotNull);
      expect(playlist.updatedAt, isNotNull);
    });

    test('should handle PlaylistEntity equality based on ID', () {
      // Arrange
      final playlist1 = PlaylistEntity(
        id: '1',
        name: 'Playlist 1',
        description: 'Description 1',
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final playlist2 = PlaylistEntity(
        id: '1', // Same ID
        name: 'Different Name', // Different name
        description: 'Different Description',
        coverImage: 'https://example.com/different.jpg',
        songs: const [
          MusicEntity(
            id: 'song1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/song1.jpg',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final playlist3 = PlaylistEntity(
        id: '2', // Different ID
        name: 'Playlist 1',
        description: 'Description 1',
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist1, equals(playlist2)); // Same ID = equal
      expect(playlist1, isNot(equals(playlist3))); // Different ID = not equal
    });

    test('should handle PlaylistEntity hashCode based on ID', () {
      // Arrange
      final playlist1 = PlaylistEntity(
        id: '1',
        name: 'Playlist 1',
        description: 'Description 1',
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final playlist2 = PlaylistEntity(
        id: '1', // Same ID
        name: 'Different Name',
        description: 'Different Description',
        coverImage: 'https://example.com/different.jpg',
        songs: const [
          MusicEntity(
            id: 'song1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/song1.jpg',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final playlist3 = PlaylistEntity(
        id: '2', // Different ID
        name: 'Playlist 1',
        description: 'Description 1',
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist1.hashCode, equals(playlist2.hashCode)); // Same ID = same hashCode
      expect(playlist1.hashCode, isNot(equals(playlist3.hashCode))); // Different ID = different hashCode
    });

    test('should handle PlaylistEntity toString', () {
      // Arrange
      final playlist = PlaylistEntity(
        id: '1',
        name: 'My Playlist',
        description: 'My Description',
        coverImage: null,
        songs: const [
          MusicEntity(
            id: 'song1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/song1.jpg',
          ),
          MusicEntity(
            id: 'song2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/song2.jpg',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final stringRepresentation = playlist.toString();

      // Assert
      expect(stringRepresentation, equals('PlaylistEntity{id: 1, name: My Playlist, songs: 2}'));
    });

    test('should handle empty songs list', () {
      // Act
      final playlist = PlaylistEntity(
        id: '1',
        name: 'Empty Playlist',
        description: 'No songs',
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist.songs, isEmpty);
      expect(playlist.toString(), contains('songs: 0'));
    });

    test('should handle multiple songs in playlist', () {
      // Act
      final playlist = PlaylistEntity(
        id: '1',
        name: 'Full Playlist',
        description: 'Many songs',
        coverImage: null,
        songs: [
          const MusicEntity(
            id: 'song1',
            title: 'Song 1',
            artist: 'Artist 1',
            imageUrl: 'https://example.com/song1.jpg',
          ),
          const MusicEntity(
            id: 'song2',
            title: 'Song 2',
            artist: 'Artist 2',
            imageUrl: 'https://example.com/song2.jpg',
          ),
          const MusicEntity(
            id: 'song3',
            title: 'Song 3',
            artist: 'Artist 3',
            imageUrl: 'https://example.com/song3.jpg',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist.songs.length, equals(3));
      expect(playlist.songs[0].title, equals('Song 1'));
      expect(playlist.songs[1].title, equals('Song 2'));
      expect(playlist.songs[2].title, equals('Song 3'));
      expect(playlist.toString(), contains('songs: 3'));
    });

    test('should handle nullable description and coverImage', () {
      // Act
      final playlist = PlaylistEntity(
        id: '1',
        name: 'Minimal Playlist',
        description: null,
        coverImage: null,
        songs: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(playlist.description, isNull);
      expect(playlist.coverImage, isNull);
      expect(playlist.name, equals('Minimal Playlist'));
    });

    test('should handle date operations', () {
      // Arrange
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));

      final playlist = PlaylistEntity(
        id: '1',
        name: 'Timed Playlist',
        description: 'With timestamps',
        coverImage: null,
        songs: const [],
        createdAt: now,
        updatedAt: later,
      );

      // Assert
      expect(playlist.createdAt, equals(now));
      expect(playlist.updatedAt, equals(later));
      expect(playlist.updatedAt.isAfter(playlist.createdAt), isTrue);
    });
  });
}

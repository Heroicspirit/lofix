import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:musicapp/features/playlist/data/repositories/playlist_repository_impl.dart';
import 'package:musicapp/features/playlist/data/datasources/remote/playlist_remote_datasource.dart';
import 'package:musicapp/core/api/api_client.dart';

// Playlist repository provider
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final remoteDataSource = PlaylistRemoteDataSourceImpl(apiClient);
  return PlaylistRepositoryImpl(remoteDataSource);
});

// User playlists provider
final userPlaylistsProvider = FutureProvider<List<PlaylistEntity>>((ref) async {
  final repository = ref.read(playlistRepositoryProvider);
  return repository.getUserPlaylists();
});

// Current playlist provider
final currentPlaylistProvider = StateProvider<PlaylistEntity?>((ref) => null);

// Playlist loading state provider
final playlistLoadingProvider = StateProvider<bool>((ref) => false);

// Playlist actions provider
class PlaylistNotifier extends StateNotifier<List<PlaylistEntity>> {
  final PlaylistRepository _repository;

  PlaylistNotifier(this._repository) : super([]);

  Future<void> loadPlaylists() async {
    state = [];
    try {
      final playlists = await _repository.getUserPlaylists();
      state = playlists;
    } catch (e) {
      // Handle error
      print('Error loading playlists: $e');
    }
  }

  Future<PlaylistEntity> createPlaylist(String name, {String? description}) async {
    try {
      final newPlaylist = await _repository.createPlaylist(name, description: description);
      state = [...state, newPlaylist];
      return newPlaylist;
    } catch (e) {
      print('Error creating playlist: $e');
      rethrow;
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _repository.deletePlaylist(id);
      state = state.where((playlist) => playlist.id != id).toList();
    } catch (e) {
      print('Error deleting playlist: $e');
      rethrow;
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      // Find the playlist and song to update
      final playlist = state.firstWhere((p) => p.id == playlistId);
      final updatedPlaylist = await _repository.addSongToPlaylist(playlistId, MusicEntity(
        id: songId,
        title: '',
        artist: '',
        imageUrl: '',
      ));
      
      // Update state with the updated playlist
      state = state.map((p) => p.id == playlistId ? updatedPlaylist : p).toList();
    } catch (e) {
      print('Error adding song to playlist: $e');
      rethrow;
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final updatedPlaylist = await _repository.removeSongFromPlaylist(playlistId, songId);
      
      // Update state with the updated playlist
      state = state.map((p) => p.id == playlistId ? updatedPlaylist : p).toList();
    } catch (e) {
      print('Error removing song from playlist: $e');
      rethrow;
    }
  }
}

final playlistNotifierProvider = StateNotifierProvider<PlaylistNotifier, List<PlaylistEntity>>((ref) {
  final repository = ref.read(playlistRepositoryProvider);
  return PlaylistNotifier(repository);
});

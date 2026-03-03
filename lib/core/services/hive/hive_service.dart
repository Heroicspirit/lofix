import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:musicapp/features/playlist/data/models/playlist_hive_model.dart';
import 'package:musicapp/features/music/data/models/song_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    // Register Adapters
    _registerAdapter();
    
    // Open necessary boxes
    await _openBoxes();
  }

  // Adapter registration
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.playlistTypeId)) {
      Hive.registerAdapter(PlaylistHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.songTypeId)) {
      Hive.registerAdapter(SongHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
    await Hive.openBox<PlaylistHiveModel>(HiveTableConstant.playlistBoxName);
    await Hive.openBox<SongHiveModel>(HiveTableConstant.songBoxName);
  }

  // Helper getter for Auth Box
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authBoxName);

  // Helper getter for Playlist Box
  Box<PlaylistHiveModel> get _playlistBox =>
      Hive.box<PlaylistHiveModel>(HiveTableConstant.playlistBoxName);

  // Helper getter for Song Box
  Box<SongHiveModel> get _songBox =>
      Hive.box<SongHiveModel>(HiveTableConstant.songBoxName);

  // ======================== AUTH QUERIES ========================== //

  /// Register a new user
  Future<void> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
  }

  /// Login - find user by email and password
  /// Returns AuthHiveModel if found, null otherwise
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if an email is already registered (Validation)
  Future<bool> isEmailRegistered(String email) async {
    return _authBox.values.any((user) => user.email == email);
  }

  /// Get user by their Unique ID (authId)
  Future<AuthHiveModel?> getUserById(String authId) async {
    return _authBox.get(authId);
  }

  /// Get user by email address
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Update existing user information
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  /// Delete user from local database
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  /// Clear all auth data (Useful for full logout/factory reset)
  Future<void> clearAllData() async {
    await _authBox.clear();
    await _playlistBox.clear();
    await _songBox.clear();
  }

  

  /// Save playlists to local storage (for offline mode)
  Future<void> savePlaylists(List<PlaylistHiveModel> playlists) async {
    try {
      await _playlistBox.clear();
      for (var playlist in playlists) {
        await _playlistBox.put(playlist.id, playlist);
      }
    } catch (e) {
      print('Error saving playlists to Hive: $e');
    }
  }

  /// Get all playlists from local storage
  Future<List<PlaylistHiveModel>> getPlaylists() async {
    try {
      return _playlistBox.values.toList();
    } catch (e) {
      print('Error getting playlists from Hive: $e');
      return [];
    }
  }

  /// Save single playlist to local storage
  Future<void> savePlaylist(PlaylistHiveModel playlist) async {
    try {
      await _playlistBox.put(playlist.id, playlist);
    } catch (e) {
      print('Error saving playlist to Hive: $e');
    }
  }

  /// Delete playlist from local storage
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _playlistBox.delete(playlistId);
    } catch (e) {
      print('Error deleting playlist from Hive: $e');
    }
  }

  /// Add song to playlist in local storage
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final playlist = _playlistBox.get(playlistId);
      if (playlist != null && !playlist.songIds.contains(songId)) {
        final updatedSongIds = List<String>.from(playlist.songIds)..add(songId);
        final updatedPlaylist = PlaylistHiveModel(
          id: playlist.id,
          name: playlist.name,
          coverImage: playlist.coverImage,
          createdAt: playlist.createdAt,
          updatedAt: DateTime.now(),
          songIds: updatedSongIds,
        );
        await _playlistBox.put(playlistId, updatedPlaylist);
      }
    } catch (e) {
      print('Error adding song to playlist in Hive: $e');
    }
  }

  /// Remove song from playlist in local storage
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final playlist = _playlistBox.get(playlistId);
      if (playlist != null) {
        final updatedSongIds = playlist.songIds.where((id) => id != songId).toList();
        final updatedPlaylist = PlaylistHiveModel(
          id: playlist.id,
          name: playlist.name,
          coverImage: playlist.coverImage,
          createdAt: playlist.createdAt,
          updatedAt: DateTime.now(),
          songIds: updatedSongIds,
        );
        await _playlistBox.put(playlistId, updatedPlaylist);
      }
    } catch (e) {
      print('Error removing song from playlist in Hive: $e');
    }
  }

  // ======================== SONG QUERIES ========================== //

  /// Save songs to local storage (for offline mode - display only)
  Future<void> saveSongs(List<SongHiveModel> songs) async {
    try {
      await _songBox.clear();
      for (var song in songs) {
        await _songBox.put(song.id, song);
      }
    } catch (e) {
      print('Error saving songs to Hive: $e');
    }
  }

  /// Get all songs from local storage (for display only, no playback)
  Future<List<SongHiveModel>> getSongs() async {
    try {
      return _songBox.values.toList();
    } catch (e) {
      print('Error getting songs from Hive: $e');
      return [];
    }
  }

  /// Get songs by IDs from local storage
  Future<List<SongHiveModel>> getSongsByIds(List<String> songIds) async {
    try {
      return songIds
          .map((id) => _songBox.get(id))
          .where((song) => song != null)
          .cast<SongHiveModel>()
          .toList();
    } catch (e) {
      print('Error getting songs by IDs from Hive: $e');
      return [];
    }
  }

  // Box close
  Future<void> close() async {
    await Hive.close();
  }
}
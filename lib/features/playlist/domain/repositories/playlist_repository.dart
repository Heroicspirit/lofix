import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

abstract class PlaylistRepository {
  // Get all playlists for current user
  Future<List<PlaylistEntity>> getUserPlaylists();
  
  // Get playlist by ID
  Future<PlaylistEntity?> getPlaylistById(String id);
  
  // Create new playlist
  Future<PlaylistEntity> createPlaylist(String name, {String? description});
  
  // Update playlist
  Future<PlaylistEntity> updatePlaylist(String id, {String? name, String? description});
  
  // Delete playlist
  Future<void> deletePlaylist(String id);
  
  // Add song to playlist
  Future<PlaylistEntity> addSongToPlaylist(String playlistId, MusicEntity song);
  
  // Remove song from playlist
  Future<PlaylistEntity> removeSongFromPlaylist(String playlistId, String songId);
  
  // Get songs in playlist
  Future<List<MusicEntity>> getPlaylistSongs(String playlistId);
}

import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/features/playlist/data/models/playlist_model.dart';

abstract class PlaylistRemoteDataSource {
  Future<List<PlaylistModel>> getUserPlaylists();
  Future<PlaylistModel?> getPlaylistById(String id);
  Future<PlaylistModel> createPlaylist(String name, {String? description});
  Future<PlaylistModel> updatePlaylist(String id, {String? name, String? description});
  Future<void> deletePlaylist(String id);
  Future<PlaylistModel> addSongToPlaylist(String playlistId, String songId);
  Future<PlaylistModel> removeSongFromPlaylist(String playlistId, String songId);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final ApiClient _apiClient;

  PlaylistRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PlaylistModel>> getUserPlaylists() async {
    try {
      final response = await _apiClient.get('playlists');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => PlaylistModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch playlists: $e');
    }
  }

  @override
  Future<PlaylistModel?> getPlaylistById(String id) async {
    try {
      final response = await _apiClient.get('playlists/$id');
      
      if (response.statusCode == 200) {
        return PlaylistModel.fromJson(response.data['data'] ?? response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch playlist: $e');
    }
  }

  @override
  Future<PlaylistModel> createPlaylist(String name, {String? description}) async {
    try {
      final response = await _apiClient.post('playlists', data: {
        'name': name,
        'description': description,
      });
      
      if (response.statusCode == 201) {
        return PlaylistModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to create playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  @override
  Future<PlaylistModel> updatePlaylist(String id, {String? name, String? description}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final response = await _apiClient.put('playlists/$id', data: data);
      
      if (response.statusCode == 200) {
        return PlaylistModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to update playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update playlist: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String id) async {
    try {
      final response = await _apiClient.delete('playlists/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete playlist: $e');
    }
  }

  @override
  Future<PlaylistModel> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final response = await _apiClient.post('playlists/$playlistId/songs', data: {
        'songId': songId,
      });
      
      if (response.statusCode == 200) {
        return PlaylistModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to add song to playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add song to playlist: $e');
    }
  }

  @override
  Future<PlaylistModel> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final response = await _apiClient.delete('playlists/$playlistId/songs/$songId');
      
      if (response.statusCode == 200) {
        return PlaylistModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to remove song from playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove song from playlist: $e');
    }
  }
}

import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/core/api/api_endpoints.dart';
import 'package:musicapp/features/dashboard/data/models/music_model.dart';

abstract class MusicRemoteDataSource {
  Future<List<MusicModel>> getTopPicks();
  Future<List<MusicModel>> getNewReleases();
  Future<List<MusicModel>> getTrending();
  Future<List<MusicModel>> searchSongs(String query);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final ApiClient _apiClient;

  MusicRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MusicModel>> getTopPicks() async {
    try {
      // For now, use the existing /songs endpoint since top-picks doesn't exist yet
      final response = await _apiClient.get(ApiEndpoints.songs);
      
      if (response.statusCode == 200) {
        // Backend response format: { success: true, data: [...] }
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MusicModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top picks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load top picks: $e');
    }
  }

  @override
  Future<List<MusicModel>> getNewReleases() async {
    try {
      // For now, use the existing /songs endpoint since new-releases doesn't exist yet
      final response = await _apiClient.get(ApiEndpoints.songs);
      
      if (response.statusCode == 200) {
        // Backend response format: { success: true, data: [...] }
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MusicModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load new releases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load new releases: $e');
    }
  }

  @override
  Future<List<MusicModel>> getTrending() async {
    try {
      // For now, use the existing /songs endpoint since trending doesn't exist yet
      final response = await _apiClient.get(ApiEndpoints.songs);
      
      if (response.statusCode == 200) {
        // Backend response format: { success: true, data: [...] }
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MusicModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load trending: $e');
    }
  }

  @override
  Future<List<MusicModel>> searchSongs(String query) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.search}?q=$query');
      
      if (response.statusCode == 200) {
        // Backend response format: { success: true, data: [...] }
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MusicModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search songs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search songs: $e');
    }
  }
}

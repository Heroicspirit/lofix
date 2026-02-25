import 'package:musicapp/features/playlist/domain/entities/playlist_entity.dart';
import 'package:musicapp/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:musicapp/features/playlist/data/datasources/remote/playlist_remote_datasource.dart';
import 'package:musicapp/features/playlist/data/models/playlist_model.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remoteDataSource;

  PlaylistRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PlaylistEntity>> getUserPlaylists() async {
    final models = await _remoteDataSource.getUserPlaylists();
    return models.map<PlaylistEntity>((model) => model).toList();
  }

  @override
  Future<PlaylistEntity?> getPlaylistById(String id) async {
    final model = await _remoteDataSource.getPlaylistById(id);
    return model;
  }

  @override
  Future<PlaylistEntity> createPlaylist(String name, {String? description}) async {
    final model = await _remoteDataSource.createPlaylist(name, description: description);
    return model;
  }

  @override
  Future<PlaylistEntity> updatePlaylist(String id, {String? name, String? description}) async {
    final model = await _remoteDataSource.updatePlaylist(id, name: name, description: description);
    return model;
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _remoteDataSource.deletePlaylist(id);
  }

  @override
  Future<PlaylistEntity> addSongToPlaylist(String playlistId, MusicEntity song) async {
    final model = await _remoteDataSource.addSongToPlaylist(playlistId, song.id);
    return model;
  }

  @override
  Future<PlaylistEntity> removeSongFromPlaylist(String playlistId, String songId) async {
    final model = await _remoteDataSource.removeSongFromPlaylist(playlistId, songId);
    return model;
  }

  @override
  Future<List<MusicEntity>> getPlaylistSongs(String playlistId) async {
    final playlist = await _remoteDataSource.getPlaylistById(playlistId);
    return playlist?.songs ?? [];
  }
}

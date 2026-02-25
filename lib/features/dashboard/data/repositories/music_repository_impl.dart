import '../../domain/entities/music_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/remote/music_remote_datasource.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource _remoteDataSource;

  MusicRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MusicEntity>> getTopPicks() async {
    final models = await _remoteDataSource.getTopPicks();
    return models.map<MusicEntity>((model) => model).toList();
  }

  @override
  Future<List<MusicEntity>> getNewReleases() async {
    final models = await _remoteDataSource.getNewReleases();
    return models.map<MusicEntity>((model) => model).toList();
  }

  @override
  Future<List<MusicEntity>> getTrending() async {
    final models = await _remoteDataSource.getTrending();
    return models.map<MusicEntity>((model) => model).toList();
  }

  @override
  Future<List<MusicEntity>> searchSongs(String query) async {
    final models = await _remoteDataSource.searchSongs(query);
    return models.map<MusicEntity>((model) => model).toList();
  }
}

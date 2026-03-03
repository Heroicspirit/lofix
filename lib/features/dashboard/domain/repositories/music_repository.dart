// import '../entities/music_entity.dart';
import '../entities/music_entity.dart';

abstract class MusicRepository {
  Future<List<MusicEntity>> getTopPicks();
  Future<List<MusicEntity>> getNewReleases();
  Future<List<MusicEntity>> getTrending();
  Future<List<MusicEntity>> searchSongs(String query);
}

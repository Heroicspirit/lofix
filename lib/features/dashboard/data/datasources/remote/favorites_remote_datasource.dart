import 'package:dartz/dartz.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/data/models/music_model.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';

class FavoritesRemoteDataSource implements FavoritesRepository {
  final ApiClient _apiClient;

  FavoritesRemoteDataSource(this._apiClient);

  @override
  Future<Either<Failure, void>> addToFavorites(String songId) async {
    try {
      await _apiClient.post('/songs/favorites', data: {'songId': songId});
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to add song to favorites: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MusicEntity>>> getFavorites() async {
    try {
      final response = await _apiClient.get('/songs/favorites');
      final List<dynamic> songsJson = response.data['data'];
      final List<MusicEntity> songs = songsJson
          .map((songJson) => MusicModel.fromJson(songJson))
          .toList();
      return Right(songs);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to get favorite songs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String songId) async {
    try {
      await _apiClient.delete('/songs/favorites/$songId');
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to remove song from favorites: $e'));
    }
  }
}

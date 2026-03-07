import 'package:dartz/dartz.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> addToFavorites(String songId) async {
    return await _remoteDataSource.addToFavorites(songId);
  }

  @override
  Future<Either<Failure, List<MusicEntity>>> getFavorites() async {
    return await _remoteDataSource.getFavorites();
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String songId) async {
    return await _remoteDataSource.removeFromFavorites(songId);
  }
}

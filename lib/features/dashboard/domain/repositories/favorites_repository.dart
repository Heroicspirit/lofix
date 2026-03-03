import 'package:dartz/dartz.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, void>> addToFavorites(String songId);
  Future<Either<Failure, List<MusicEntity>>> getFavorites();
  Future<Either<Failure, void>> removeFromFavorites(String songId);
}

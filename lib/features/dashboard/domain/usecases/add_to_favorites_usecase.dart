import 'package:dartz/dartz.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';

class AddToFavoritesUseCase {
  final FavoritesRepository _repository;

  AddToFavoritesUseCase(this._repository);

  Future<Either<Failure, void>> call(String songId) async {
    return await _repository.addToFavorites(songId);
  }
}

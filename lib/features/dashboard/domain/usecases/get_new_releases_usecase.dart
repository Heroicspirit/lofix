import '../entities/music_entity.dart';
import '../repositories/music_repository.dart';

class GetNewReleasesUseCase {
  final MusicRepository _repository;

  GetNewReleasesUseCase(this._repository);

  Future<List<MusicEntity>> call() async {
    return await _repository.getNewReleases();
  }
}

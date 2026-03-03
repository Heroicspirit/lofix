import '../entities/music_entity.dart';
import '../repositories/music_repository.dart';

class GetTopPicksUseCase {
  final MusicRepository _repository;

  GetTopPicksUseCase(this._repository);

  Future<List<MusicEntity>> call() async {
    return await _repository.getTopPicks();
  }
}

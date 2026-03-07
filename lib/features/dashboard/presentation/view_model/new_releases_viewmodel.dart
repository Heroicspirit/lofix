import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_new_releases_usecase.dart';
import '../view_model/music_viewmodel.dart';

class NewReleasesViewModel extends StateNotifier<AsyncValue<List>> {
  final GetNewReleasesUseCase _getNewReleasesUseCase;

  NewReleasesViewModel(this._getNewReleasesUseCase) : super(const AsyncValue.loading()) {
    loadNewReleases();
  }

  Future<void> loadNewReleases() async {
    state = const AsyncValue.loading();
    try {
      final newReleases = await _getNewReleasesUseCase();
      state = AsyncValue.data(newReleases);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final newReleasesProvider = StateNotifierProvider<NewReleasesViewModel, AsyncValue<List>>(
  (ref) => NewReleasesViewModel(ref.read(getNewReleasesUseCaseProvider)),
);

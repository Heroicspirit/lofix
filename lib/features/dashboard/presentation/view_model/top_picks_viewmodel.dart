import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_top_picks_usecase.dart';
import '../view_model/music_viewmodel.dart';

class TopPicksViewModel extends StateNotifier<AsyncValue<List>> {
  final GetTopPicksUseCase _getTopPicksUseCase;

  TopPicksViewModel(this._getTopPicksUseCase) : super(const AsyncValue.loading()) {
    loadTopPicks();
  }

  Future<void> loadTopPicks() async {
    state = const AsyncValue.loading();
    try {
      final topPicks = await _getTopPicksUseCase();
      state = AsyncValue.data(topPicks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final topPicksProvider = StateNotifierProvider<TopPicksViewModel, AsyncValue<List>>(
  (ref) => TopPicksViewModel(ref.read(getTopPicksUseCaseProvider)),
);

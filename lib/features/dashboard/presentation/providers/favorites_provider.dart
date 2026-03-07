import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/presentation/providers/favorites_provider_dependencies.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<MusicEntity>>> {
  final AddToFavoritesUseCase _addToFavoritesUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final RemoveFromFavoritesUseCase _removeFromFavoritesUseCase;

  FavoritesNotifier(
    this._addToFavoritesUseCase,
    this._getFavoritesUseCase,
    this._removeFromFavoritesUseCase,
  ) : super(const AsyncValue.loading());

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    final result = await _getFavoritesUseCase();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (favorites) => state = AsyncValue.data(favorites),
    );
  }

  Future<void> addToFavorites(String songId) async {
    final currentFavorites = state.value ?? [];
    
    // Optimistically update UI
    state = AsyncValue.data(currentFavorites);
    
    final result = await _addToFavoritesUseCase(songId);
    result.fold(
      (failure) {
        // Revert on error
        state = AsyncValue.data(currentFavorites);
      },
      (_) {
        // Refresh favorites list
        loadFavorites();
      },
    );
  }

  Future<void> removeFromFavorites(String songId) async {
    final currentFavorites = state.value ?? [];
    
    // Optimistically update UI
    final updatedFavorites = currentFavorites.where((song) => song.id != songId).toList();
    state = AsyncValue.data(updatedFavorites);
    
    final result = await _removeFromFavoritesUseCase(songId);
    result.fold(
      (failure) {
        // Revert on error
        state = AsyncValue.data(currentFavorites);
      },
      (_) {
        // Keep the optimistic update
        state = AsyncValue.data(updatedFavorites);
      },
    );
  }

  bool isFavorite(String songId) {
    final favorites = state.value ?? [];
    return favorites.any((song) => song.id == songId);
  }
}

// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<MusicEntity>>>((ref) {
  return FavoritesNotifier(
    ref.read(addToFavoritesUseCaseProvider),
    ref.read(getFavoritesUseCaseProvider),
    ref.read(removeFromFavoritesUseCaseProvider),
  );
});

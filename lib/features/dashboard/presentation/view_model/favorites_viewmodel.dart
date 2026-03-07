import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:musicapp/features/dashboard/data/repositories/favorites_repository_impl.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';

// Favorites Repository Provider
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final remoteDataSource = FavoritesRemoteDataSource(apiClient);
  return FavoritesRepositoryImpl(remoteDataSource);
});

// Favorites UseCase Providers
final addToFavoritesUseCaseProvider = Provider<AddToFavoritesUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return AddToFavoritesUseCase(repository);
});

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return GetFavoritesUseCase(repository);
});

final removeFromFavoritesUseCaseProvider = Provider<RemoveFromFavoritesUseCase>((ref) {
  final repository = ref.read(favoritesRepositoryProvider);
  return RemoveFromFavoritesUseCase(repository);
});


class FavoritesViewModel extends StateNotifier<AsyncValue<List<MusicEntity>>> {
  final AddToFavoritesUseCase _addToFavoritesUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final RemoveFromFavoritesUseCase _removeFromFavoritesUseCase;

  FavoritesViewModel(
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

final favoritesProvider = StateNotifierProvider<FavoritesViewModel, AsyncValue<List<MusicEntity>>>((ref) {
  return FavoritesViewModel(
    ref.read(addToFavoritesUseCaseProvider),
    ref.read(getFavoritesUseCaseProvider),
    ref.read(removeFromFavoritesUseCaseProvider),
  );
});

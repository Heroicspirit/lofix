import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:musicapp/features/dashboard/data/repositories/favorites_repository_impl.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';
import 'package:musicapp/core/services/storage/favorites_storage_service.dart';
import 'package:musicapp/core/error/failures.dart';

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
  final FavoritesStorageService _favoritesStorageService;

  FavoritesViewModel(
    this._addToFavoritesUseCase,
    this._getFavoritesUseCase,
    this._removeFromFavoritesUseCase,
    this._favoritesStorageService,
  ) : super(const AsyncValue.loading());

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    final result = await _getFavoritesUseCase();
    result.fold(
      (failure) {
        // If backend fails, try to load from local storage
        _loadFromLocalStorage();
      },
      (favorites) {
        state = AsyncValue.data(favorites);
        // Also update local storage with latest favorites
        final favoriteIds = favorites.map((song) => song.id).toList();
        _favoritesStorageService.saveFavorites(favoriteIds);
      },
    );
  }

  // Load favorites from local storage (fallback)
  Future<void> _loadFromLocalStorage() async {
    try {
      final favoriteIds = _favoritesStorageService.getFavorites();
      // Note: This would need to be implemented to fetch full MusicEntity objects
      // For now, we'll just set empty state
      state = const AsyncValue.data([]);
    } catch (e) {
      state = AsyncValue.error(
        ApiFailure(message: 'Failed to load favorites: $e'),
        StackTrace.current,
      );
    }
  }

  // Initialize favorites on app startup
  Future<void> initializeFavorites() async {
    // Try to load from backend first
    await loadFavorites();
  }

  Future<void> addToFavorites(String songId) async {
    final currentFavorites = state.value ?? [];
    
    // Optimistically update UI
    state = AsyncValue.data(currentFavorites);
    
    // Update local storage immediately
    await _favoritesStorageService.addToFavorites(songId);
    
    final result = await _addToFavoritesUseCase(songId);
    result.fold(
      (failure) {
        // Revert local storage on error
        _favoritesStorageService.removeFromFavorites(songId);
        // Revert UI state
        state = AsyncValue.data(currentFavorites);
      },
      (_) {
        // Refresh favorites list from backend
        loadFavorites();
      },
    );
  }

  Future<void> removeFromFavorites(String songId) async {
    final currentFavorites = state.value ?? [];
    
    // Optimistically update UI
    final updatedFavorites = currentFavorites.where((song) => song.id != songId).toList();
    state = AsyncValue.data(updatedFavorites);
    
    // Update local storage immediately
    await _favoritesStorageService.removeFromFavorites(songId);
    
    final result = await _removeFromFavoritesUseCase(songId);
    result.fold(
      (failure) {
        // Revert local storage on error
        _favoritesStorageService.addToFavorites(songId);
        // Revert UI state
        state = AsyncValue.data(currentFavorites);
      },
      (_) {
        // Keep the optimistic update
        state = AsyncValue.data(updatedFavorites);
      },
    );
  }

  bool isFavorite(String songId) {
    // Check local storage first for immediate response
    if (_favoritesStorageService.isFavorite(songId)) {
      return true;
    }
    
    // Fall back to current state
    final favorites = state.value ?? [];
    return favorites.any((song) => song.id == songId);
  }

  // Clear local favorites (for logout)
  Future<void> clearFavorites() async {
    await _favoritesStorageService.clearFavorites();
    state = const AsyncValue.data([]);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesViewModel, AsyncValue<List<MusicEntity>>>((ref) {
  return FavoritesViewModel(
    ref.read(addToFavoritesUseCaseProvider),
    ref.read(getFavoritesUseCaseProvider),
    ref.read(removeFromFavoritesUseCaseProvider),
    ref.read(favoritesStorageServiceProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/api/api_client.dart';
import 'package:musicapp/features/dashboard/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:musicapp/features/dashboard/data/repositories/favorites_repository_impl.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';
import 'package:musicapp/features/dashboard/domain/entities/music_entity.dart';
import 'package:musicapp/features/dashboard/domain/usecases/add_to_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';
import 'package:musicapp/features/dashboard/presentation/providers/favorites_provider.dart';

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

// Favorites Notifier Provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<MusicEntity>>>((ref) {
  final addToFavoritesUseCase = ref.read(addToFavoritesUseCaseProvider);
  final getFavoritesUseCase = ref.read(getFavoritesUseCaseProvider);
  final removeFromFavoritesUseCase = ref.read(removeFromFavoritesUseCaseProvider);
  
  return FavoritesNotifier(
    addToFavoritesUseCase,
    getFavoritesUseCase,
    removeFromFavoritesUseCase,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesStorageServiceProvider = Provider<FavoritesStorageService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return FavoritesStorageService(prefs: sharedPreferences);
});

class FavoritesStorageService {
  final SharedPreferences _prefs;
  static const String _favoritesKey = 'user_favorites';

  FavoritesStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save favorites list to local storage
  Future<void> saveFavorites(List<String> songIds) async {
    await _prefs.setStringList(_favoritesKey, songIds);
  }

  // Get favorites list from local storage
  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  // Add a song to favorites
  Future<void> addToFavorites(String songId) async {
    final currentFavorites = getFavorites();
    if (!currentFavorites.contains(songId)) {
      currentFavorites.add(songId);
      await saveFavorites(currentFavorites);
    }
  }

  // Remove a song from favorites
  Future<void> removeFromFavorites(String songId) async {
    final currentFavorites = getFavorites();
    currentFavorites.remove(songId);
    await saveFavorites(currentFavorites);
  }

  // Check if a song is in favorites
  bool isFavorite(String songId) {
    return getFavorites().contains(songId);
  }

  // Clear all favorites (for logout)
  Future<void> clearFavorites() async {
    await _prefs.remove(_favoritesKey);
  }

  // Get favorites count
  int getFavoritesCount() {
    return getFavorites().length;
  }
}

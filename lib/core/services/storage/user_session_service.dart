import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("Shared prefs implementation in the main ");
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  //keys for storing data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUsername = 'username';
  static const String _keyUserProfileImage = 'user_profile_image';

  //store user session data
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
  
    String? profileImage,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUsername, username);
    if (profileImage != null) {
      await _prefs.setString(_keyUserProfileImage, profileImage);
    }
  }

  //clear user session

  Future<void> clearUserSession() async {

    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserProfileImage);
  }

  //check if logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }
   String? getUsername() {
    return _prefs.getString(_keyUsername);
  }


  String? getUserProfileImage() {
    return _prefs.getString(_keyUserProfileImage);
  }
}
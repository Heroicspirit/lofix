import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/hive/hive_service.dart';
import 'package:musicapp/core/services/storage/token_service.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/data/datasources/auth_datasource.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  final tokenService = ref.read(tokenServiceProvider);

  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
    tokenService: tokenService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.login(email, password);
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          name: user.name,
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  // ✅ OPTION 2: returns user + auto-login
  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    try {
      await _hiveService.register(user);

      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        name: user.name,
      );

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      final userId = _userSessionService.getUserId();
      if (userId == null) return null;

      return await _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearUserSession();
      await _tokenService.removeToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return await _hiveService.isEmailRegistered(email);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return await _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return await _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

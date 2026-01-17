import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    // Register Adapters
    _registerAdapter();
    
    // Open necessary boxes
    await _openBoxes();
  }

  // Adapter registration
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    // Add additional adapters here as you create more features
  }

  // Open Boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
  }

  // Helper getter for Auth Box
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authBoxName);

  // ======================== AUTH QUERIES ========================== //

  /// Register a new user
  Future<void> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
  }

  /// Login - find user by email and password
  /// Returns AuthHiveModel if found, null otherwise
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if an email is already registered (Validation)
  Future<bool> isEmailRegistered(String email) async {
    return _authBox.values.any((user) => user.email == email);
  }

  /// Get user by their Unique ID (authId)
  Future<AuthHiveModel?> getUserById(String authId) async {
    return _authBox.get(authId);
  }

  /// Get user by email address
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Update existing user information
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  /// Delete user from local database
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  /// Clear all auth data (Useful for full logout/factory reset)
  Future<void> clearAllData() async {
    await _authBox.clear();
  }

  // Box close
  Future<void> close() async {
    await Hive.close();
  }
}
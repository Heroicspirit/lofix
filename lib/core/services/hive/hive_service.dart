import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  static final Map<String, AuthHiveModel> _webStorage = {};

  Future<void> init() async {
    if (!kIsWeb) {
      final directory = await getApplicationCacheDirectory();
      // Ensure directory exists
      final path = '${directory.path}/${HiveTableConstant.dbName}';
      Hive.init(path);
      _registerAdapter();
    }
  }

  void _registerAdapter() {
    // Note: Removed !kIsWeb check here to allow registration if needed, 
    // though init only calls this for non-web.
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    if (!kIsWeb) {
      try {
        await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
      } catch (e) {
        // CORRUPTION FIX: If the binary file is broken, delete it and reopen.
        debugPrint("Hive box corrupted, deleting... Error: $e");
        await Hive.deleteBoxFromDisk(HiveTableConstant.authBoxName);
        await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
      }
    }
  }

  Future<void> close() async {
    if (!kIsWeb) {
      await Hive.close();
    }
  }

  Box<AuthHiveModel> get _authBox {
    if (kIsWeb) {
      throw UnsupportedError('Hive box not available on web');
    }
    return Hive.box<AuthHiveModel>(HiveTableConstant.authBoxName);
  }

  // Register user
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    if (isEmailExists(model.email)) {
      throw Exception('Email already exists');
    }

    if (kIsWeb) {
      _webStorage[model.authId!] = model;
    } else {
      // Ensure we use a unique key, like email or authId
      await _authBox.put(model.authId ?? model.email, model);
    }
    return model;
  }

  // Login user
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    if (kIsWeb) {
      final users = _webStorage.values.where(
        (user) => user.email == email && user.password == password,
      );
      return users.isNotEmpty ? users.first : null;
    } else {
      final users = _authBox.values.where(
        (user) => user.email == email && user.password == password,
      );
      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    }
  }

  Future<void> logoutUser() async {}

  AuthHiveModel? getCurrentUser(String authId) {
    if (kIsWeb) {
      return _webStorage[authId];
    } else {
      return _authBox.get(authId);
    }
  }

  bool isEmailExists(String email) {
    if (kIsWeb) {
      final users = _webStorage.values.where((user) => user.email == email);
      return users.isNotEmpty;
    } else {
      final users = _authBox.values.where((user) => user.email == email);
      return users.isNotEmpty;
    }
  }
}
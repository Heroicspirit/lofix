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
      final path = '${directory.path}/${HiveTableConstant.dbName}';
      Hive.init(path);
      _registerAdapter();
    }
  }

  void _registerAdapter() {
    if (!kIsWeb && !Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    if (!kIsWeb) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
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

  //regiseter user ko lagi
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    // Check if email already exists
    if (isEmailExists(model.email)) {
      throw Exception('Email already exists');
    }
    
    if (kIsWeb) {
      // Use in-memory storage for web
      _webStorage[model.authId!] = model;
    } else {
      // Use Hive for mobile/desktop
      await _authBox.put(model.authId, model);
    }
    return model;
  }

  //Login user ko lagi
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    if (kIsWeb) {
      // Use in-memory storage for web
      final users = _webStorage.values.where(
        (user) => user.email == email && user.password == password,
      );
      return users.isNotEmpty ? users.first : null;
    } else {
      // Use Hive for mobile/desktop
      final users = _authBox.values.where(
        (user) => user.email == email && user.password == password,
      );
      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    }
  }

  //logout ko lagi
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String authId) {
    if (kIsWeb) {
      return _webStorage[authId];
    } else {
      return _authBox.get(authId);
    }
  }

  //isemail exists
  bool isEmailExists(String email) {
    if (kIsWeb) {
      // Use in-memory storage for web
      final users = _webStorage.values.where((user) => user.email == email);
      return users.isNotEmpty;
    } else {
      // Use Hive for mobile/desktop
      final users = _authBox.values.where((user) => user.email == email);
      return users.isNotEmpty;
    }
  }
}
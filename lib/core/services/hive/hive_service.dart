import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AuthHiveModelAdapter());
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
  }


  Future<void> register(AuthHiveModel authHiveModel) async {
    var box = Hive.box<AuthHiveModel>(HiveTableConstant.authBoxName);
    await box.put(authHiveModel.username, authHiveModel);
  }


  Future<AuthHiveModel?> login(String username, String password) async {
    var box = Hive.box<AuthHiveModel>(HiveTableConstant.authBoxName);
    var user = box.get(username);

    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }


  Future<void> logout() async {
  }
}
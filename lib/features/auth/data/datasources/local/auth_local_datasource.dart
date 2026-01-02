

import 'package:musicapp/core/services/hive/hive_service.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';

abstract class IAuthLocalDataSource {
  Future<void> registerUser(AuthEntity entity);
  Future<AuthEntity> loginUser(String username, String password);
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final HiveService _hiveService;

  AuthLocalDataSource(this._hiveService);

  @override
  Future<void> registerUser(AuthEntity entity) async {
    try {
      final hiveModel = AuthHiveModel.fromEntity(entity);
      
      await _hiveService.register(hiveModel);
    } catch (e) {
      throw Exception("Local Registration Failed: $e");
    }
  }

  @override
  Future<AuthEntity> loginUser(String email, String password) async {
    try {
      final AuthHiveModel? userModel = await _hiveService.login(email, password);

      if (userModel != null) {
        return userModel.toEntity();
      } else {
        throw Exception("Invalid Username or Password");
      }
    } catch (e) {
      throw Exception("Local Login Failed: $e");
    }
  }
}
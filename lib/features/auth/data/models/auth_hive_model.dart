import 'package:hive/hive.dart';
import 'package:musicapp/core/constants/hive_table_constant.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';
@HiveType(typeId: HiveTableConstant.authTypeId)

class AuthHiveModel  extends HiveObject {
  
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String username;
  @HiveField(4)
  final String? password;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
  }) : authId = authId ?? Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity enitiy){
    return AuthHiveModel(
      authId: enitiy.authId,
      fullName: enitiy.fullName,
      email: enitiy.email,
      username: enitiy.username,
      password: enitiy.password,
    );
  }

  AuthEntity toEntity(){
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      username: username,
      password: password,
    );
  }


  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
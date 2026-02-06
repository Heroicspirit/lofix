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
  final String email;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String? password;
  @HiveField(4)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.email,
    required this.name,
    this.password,
    this.profilePicture,
  }) : authId = authId ?? Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity enitiy){
    return AuthHiveModel(
      authId: enitiy.authId,
      email: enitiy.email,
      name: enitiy.name,
      password: enitiy.password,
      profilePicture: enitiy.profilePicture,
    );
  }

  AuthEntity toEntity(){
    return AuthEntity(
      authId: authId,
      email: email,
      name: name,
      password: password,
      profilePicture: profilePicture,
    );
  }


  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
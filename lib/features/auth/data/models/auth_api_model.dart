import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
class AuthApiModel {
  final String? authId;
  final String email;
  final String name;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    this.authId,
    required this.email,
    required this.name,
    this.password,
    this.profilePicture,
  });

  //to Json

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "name": name,
      "password" : password,
      "confirmPassword": password,
      "profilePicture": profilePicture,
    };
  }

  // fromJson

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  //toEntity

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      email: email,
      name: name,
      profilePicture: profilePicture,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      email: entity.email,
      name: entity.name,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  //toEntityList

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
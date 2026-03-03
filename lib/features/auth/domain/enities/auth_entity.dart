import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String email;
  final String name;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture; 

  const AuthEntity({
    this.authId, 
    required this.email, 
    required this.name, 
    this.password,
    this.confirmPassword,
    this.profilePicture
  });

  @override
  List<Object?> get props => [
    authId, 
    email, 
    name, 
    password, 
    confirmPassword,
    profilePicture
  ];

  AuthEntity copyWith({
    String? authId,
    String? email,
    String? name,
    String? password,
    String? confirmPassword,
    String? profilePicture,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
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
}
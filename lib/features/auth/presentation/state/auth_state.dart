import 'package:equatable/equatable.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';


enum AuthStatus { initial, loading, authenticated, unauthenticated, registered, loaded,error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  final String? uploadPhotoName;


  const AuthState({
    required this.status,
    this.authEntity,
    this.errorMessage,
    this.uploadPhotoName,
  });

  // Initial State Factory
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      authEntity: null,
      errorMessage: null,
    );
  }

  // CopyWith Method
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
    String? uploadPhotoName,
  }) {
    return AuthState(
      status: status ?? this.status,

      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadPhotoName: uploadPhotoName ?? this.uploadPhotoName,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}
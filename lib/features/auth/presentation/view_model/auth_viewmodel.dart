import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';

// Provider definition
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final UploadPhotoUsecase _uploadPhotoUsecase;


  @override
  AuthState build() {
    // Initialize all usecases
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    
    return AuthState.initial(); 
  }

  /// Register User
  Future<void> register({
    required String email,
    required String name,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      email: email,
      name: name,
      password: password,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isRegistered) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  /// Login User
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(email: email, password: password);

    final result = await _loginUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }


  /// Get Current User (Used for Session Persistence)
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated, 
        authEntity: user,
      ),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) =>
          state = AuthState.initial(), // Reset to unauthenticated/initial state
    );
  }

  Future<void> uploadPhoto(File photo) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadPhotoUsecase(photo);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (imageName) {
        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadPhotoName: imageName,
        );
      },
    );
  }

  /// Reset State
  void resetState() {
    state = AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
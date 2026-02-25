import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:musicapp/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:musicapp/features/auth/presentation/state/auth_state.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(
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
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);

    return AuthState.initial();
  }

  // ===========================
  // REGISTER
  // ===========================

  Future<void> register({
    required String email,
    required String name,
    required String password,
    String? confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      email: email,
      name: name,
      password: password,
      confirmPassword: confirmPassword,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  // ===========================
  // LOGIN
  // ===========================

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(
      email: email,
      password: password,
    );

    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) async {
        final userSessionService =
            ref.read(userSessionServiceProvider);

        // 🔥 FIX: Store in local variable for null promotion
        final userId = authEntity.authId;

        if (userId != null) {
          await userSessionService.saveUserSession(
            userId: userId,
            email: authEntity.email,
            name: authEntity.name,
            profilePicture: authEntity.profilePicture,
          );
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  // ===========================
  // GET CURRENT USER
  // ===========================

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) async {
        final userSessionService =
            ref.read(userSessionServiceProvider);

        final userId = user.authId;

        if (userId != null) {
          await userSessionService.saveUserSession(
            userId: userId,
            email: user.email,
            name: user.name,
            profilePicture: user.profilePicture,
          );
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: user,
        );
      },
    );
  }

  // ===========================
  // UPLOAD PHOTO
  // ===========================

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
      (imageName) async {
        // ✅ Update local session after upload
        final userSessionService =
            ref.read(userSessionServiceProvider);

        await userSessionService.saveUserProfileImage(imageName);

        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadPhotoName: imageName,
        );
      },
    );
  }

  // ===========================
  // UPDATE USER NAME
  // ===========================

  Future<void> updateUserName(String name) async {
    try {
      final userSessionService = ref.read(userSessionServiceProvider);
      await userSessionService.updateUserName(name);
      
      // Also update the current auth entity if it exists
      if (state.authEntity != null) {
        final updatedAuthEntity = state.authEntity!.copyWith(name: name);
        state = state.copyWith(authEntity: updatedAuthEntity);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update user name: $e',
      );
    }
  }

  // ===========================
  // LOGOUT
  // ===========================

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) async {
        final userSessionService =
            ref.read(userSessionServiceProvider);

        await userSessionService.clearSession();

        state = AuthState.initial();
      },
    );
  }

  // ===========================
  // HELPERS
  // ===========================

  void resetState() {
    state = AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

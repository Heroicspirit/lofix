import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/usecases/app_usecase.dart';
import 'package:musicapp/features/auth/data/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';


// 1. Create the Provider for the Logout Usecase
final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  // Reading the AuthRepository (Interface) from its provider
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

// 2. Define the Usecase Class
class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() async {
    // Calls the logout method in the repository which handles 
    // clearing Hive boxes and SharedPreferences
    return await _authRepository.logout();
  }
}
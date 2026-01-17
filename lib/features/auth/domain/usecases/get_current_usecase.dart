import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/usecases/app_usecase.dart';
import 'package:musicapp/features/auth/data/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';



final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {

  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});


class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() async {

    return await _authRepository.getCurrentUser();
  }
}
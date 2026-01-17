import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/usecases/app_usecase.dart';
import 'package:musicapp/features/auth/data/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';


class RegisterUsecaseParams extends Equatable {
  final String email;
  final String name;
  final String password;

  const RegisterUsecaseParams({
    required this.email,
    required this.name,
    required this.password,
  });
  @override
  List<Object?> get props => [email, name, password];
}

//provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});



class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      email: params.email,
      name: params.name,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}
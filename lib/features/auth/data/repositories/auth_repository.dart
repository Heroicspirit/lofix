import 'package:dartz/dartz.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
abstract class IAuthRepository {
  Future<Either<Failure, void>> registerUser(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password);
}

import 'package:dartz/dartz.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register ( AuthEntity enitiy);
  Future<Either<Failure, AuthEntity>> login ( String username, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser ();
  Future<Either<Failure, bool>> logout ();
}


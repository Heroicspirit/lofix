import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/data/datasources/auth_datasource.dart';
import 'package:musicapp/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';


//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authDatasource: ref.read(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDataSource;

  AuthRepository({required IAuthDataSource authDatasource})
    : _authDataSource = authDatasource;
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }

      return Left(LocalDatabaseFailure(message: 'No user logged in '));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDataSource.login(email, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDataSource.register(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register user'));
    } catch (e) {
      String errorMessage = 'Failed to register user';
      if (e.toString().contains('Email already exists')) {
        errorMessage = 'Email already exists';
      } else {
        errorMessage = e.toString();
      }
      return Left(LocalDatabaseFailure(message: errorMessage));
    }
  }
}
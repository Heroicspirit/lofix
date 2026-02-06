import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/services/connectivity/network_info.dart';
import 'package:musicapp/features/auth/data/datasources/auth_datasource.dart';
import 'package:musicapp/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:musicapp/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:musicapp/features/auth/data/models/auth_api_model.dart';
import 'package:musicapp/features/auth/data/models/auth_hive_model.dart';
import 'package:musicapp/features/auth/domain/enities/auth_entity.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';

// provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _authLocalDatasource = authDatasource,
        _authRemoteDataSource = authRemoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel =
            await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }
        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        String errorMessage = 'Login Failed';
        
        // Safely extract error message from response
        if (e.response?.data != null) {
          if (e.response!.data is Map) {
            errorMessage = e.response!.data['message'] ?? errorMessage;
          } else if (e.response!.data is String) {
            // Handle HTML error pages or plain text responses
            errorMessage = 'Server error: ${e.response!.statusCode}';
          }
        }
        
        return Left(
          ApiFailure(
            message: errorMessage,
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user =
            await _authLocalDatasource.login(email, password);
        if (user != null) {
          return Right(user.toEntity());
        }
        return Left(
          LocalDatabaseFailure(message: 'Invalid email or password'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    print('Repository: Starting register for ${user.email}');
    
    if (await _networkInfo.isConnected) {
      print(' Online mode - calling API');
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        print(' Calling remote datasource');
        await _authRemoteDataSource.register(apiModel);
        print(' API registration successful');
        return const Right(true);
      } on DioException catch (e) {
        print(' DioException: ${e.message}');
        
        String errorMessage = 'Registration Failed';
        
        // Safely extract error message from response
        if (e.response?.data != null) {
          if (e.response!.data is Map) {
            errorMessage = e.response!.data['message'] ?? errorMessage;
          } else if (e.response!.data is String) {
            // Handle HTML error pages or plain text responses
            errorMessage = 'Server error: ${e.response!.statusCode}';
          }
        }
        
        return Left(
          ApiFailure(
            message: errorMessage,
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        print(' API Exception: ${e.toString()}');
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      print('📱 Offline mode - using local storage');
      try {
        final model = AuthHiveModel.fromEntity(user);

        //  returns AuthHiveModel
        final savedUser = await _authLocalDatasource.register(model);

        if (savedUser.authId != null) {
          print(' Local registration successful');
          return const Right(true);
        }

        return Left(
          LocalDatabaseFailure(message: "Failed to register user"),
        );
      } catch (e) {
        print(' Local Exception: ${e.toString()}');
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return Left(
        LocalDatabaseFailure(message: "Failed to logout user"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return await _authLocalDatasource.isEmailExists(email);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String authId) async {
    try {
      final result = await _authLocalDatasource.deleteUser(authId);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getUserByEmail(String email) async {
    try {
      final user = await _authLocalDatasource.getUserByEmail(email);
      return Right(user?.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getUserById(String authId) async {
    try {
      final user = await _authLocalDatasource.getUserById(authId);
      return Right(user?.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUser(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authLocalDatasource.updateUser(model);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final fileName = await _authRemoteDataSource.uploadImage(image);
        return Right(fileName);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(ApiFailure(message: 'No internet connection'));
    }
  }
}

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/core/usecases/app_usecase.dart';
import 'package:musicapp/features/auth/data/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';


final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UploadPhotoUsecase(repository: repository);
});

class UploadPhotoUsecase implements UsecaseWithParams<String, File> {
  final IAuthRepository _repository;
  UploadPhotoUsecase({required IAuthRepository repository})
    : _repository = repository;
  @override
  Future<Either<Failure, String>> call(File params) {
    return _repository.uploadImage(params);
  }
}
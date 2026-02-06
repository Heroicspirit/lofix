import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:musicapp/features/auth/domain/usecases/upload_photo_usecase.dart';

// 1. Mock the Repository Interface
class MockAuthRepository extends Mock implements IAuthRepository {}

// 2. Mock the File class
class MockFile extends Mock implements File {}

// 3. Create a Fake File for Mocktail's fallback registration
class FakeFile extends Fake implements File {}

void main() {
  late UploadPhotoUsecase usecase;
  late MockAuthRepository mockAuthRepository;
  late MockFile mockFile;

  // 4. Register the fallback value before tests run
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockFile = MockFile();
    usecase = UploadPhotoUsecase(repository: mockAuthRepository);
  });

  const tImageUrl = "https://musicapp.com/uploads/profile_picture.jpg";
  final tFailure = ApiFailure(message: "Upload failed");

  group('UploadPhotoUsecase Unit Tests', () {
    
    test('should call uploadImage on the repository with the correct file', () async {
      // Arrange
      when(() => mockAuthRepository.uploadImage(any()))
          .thenAnswer((_) async => const Right(tImageUrl));

      // Act
      final result = await usecase(mockFile);

      // Assert
      expect(result, const Right(tImageUrl));
      verify(() => mockAuthRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Failure when repository upload fails', () async {
      // Arrange
      when(() => mockAuthRepository.uploadImage(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase(mockFile);

      // Assert
      expect(result, Left(tFailure));
      verify(() => mockAuthRepository.uploadImage(mockFile)).called(1);
    });
  });
}
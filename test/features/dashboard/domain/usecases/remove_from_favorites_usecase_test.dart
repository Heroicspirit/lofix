import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:musicapp/core/error/failures.dart';
import 'package:musicapp/features/dashboard/domain/repositories/favorites_repository.dart';
import 'package:musicapp/features/dashboard/domain/usecases/remove_from_favorites_usecase.dart';

void main() {
  group('RemoveFromFavoritesUseCase', () {
    late FavoritesRepository mockRepository;
    late RemoveFromFavoritesUseCase useCase;

    setUp(() {
      mockRepository = MockFavoritesRepository();
      useCase = RemoveFromFavoritesUseCase(mockRepository);
    });

    test('should call repository with correct song ID', () async {
      // Arrange
      when(() => mockRepository.removeFromFavorites('test-song-id'))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call('test-song-id');

      // Assert
      verify(() => mockRepository.removeFromFavorites('test-song-id')).called(1);
    });

    test('should return Right when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.removeFromFavorites('test-song-id'))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call('test-song-id');

      // Assert
      expect(result, isA<Right<Failure, void>>());
    });

    test('should return Left when repository fails', () async {
      // Arrange
      const testFailure = ApiFailure(message: 'Failed to remove from favorites');
      when(() => mockRepository.removeFromFavorites('test-song-id'))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase.call('test-song-id');

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (l) => expect(l, equals(testFailure)),
        (r) => fail('Should not succeed'),
      );
    });

    test('should handle empty song ID', () async {
      // Act & Assert
      expect(() => useCase.call(''), throwsA(isA<TypeError>()));
    });

    test('should handle null song ID', () async {
      // Act & Assert
      expect(() => useCase.call(''), throwsA(isA<TypeError>()));
    });
  });
}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

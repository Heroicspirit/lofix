import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:musicapp/core/services/connectivity/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('NetworkInfo', () {
    late NetworkInfo networkInfo;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
      networkInfo = NetworkInfo(mockConnectivity);
    });

    test('should return true when connectivity is wifi', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isTrue);
    });

    test('should return true when connectivity is mobile', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isTrue);
    });

    test('should return false when connectivity is none', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isFalse);
    });

    test('should return false when connectivity contains none', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.none]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isFalse);
    });

    test('should return true when connectivity is ethernet', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);

      // Act
      final result = await networkInfo.isConnected;

      // Assert
      expect(result, isTrue);
    });
  });
}

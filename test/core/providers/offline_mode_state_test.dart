import 'package:flutter_test/flutter_test.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';

void main() {
  group('OfflineModeState', () {
    test('should create state with required parameters', () {
      // Act
      final state = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: true,
        hasNetwork: true,
      );

      // Assert
      expect(state.status, equals(OfflineModeStatus.online));
      expect(state.isLoggedIn, isTrue);
      expect(state.hasNetwork, isTrue);
    });

    test('should copy state with new values', () {
      // Arrange
      final originalState = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: false,
        hasNetwork: true,
      );

      // Act
      final newState = originalState.copyWith(
        isLoggedIn: true,
        status: OfflineModeStatus.offline,
      );

      // Assert
      expect(newState.status, equals(OfflineModeStatus.offline));
      expect(newState.isLoggedIn, isTrue);
      expect(newState.hasNetwork, isTrue); // Should remain unchanged
    });

    test('should have correct helper properties when online', () {
      // Arrange
      final state = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: true,
        hasNetwork: true,
      );

      // Act & Assert
      expect(state.canPlayMusic, isTrue);
      expect(state.canSearch, isTrue);
      expect(state.canEditProfile, isTrue);
      expect(state.canCreatePlaylists, isTrue);
      expect(state.canDeletePlaylists, isTrue);
      expect(state.canAddRemoveSongs, isTrue);
      expect(state.canLoadImages, isTrue);
      expect(state.canRefreshData, isTrue);
      expect(state.hasLimitedAccess, isFalse);
      expect(state.isFullyOffline, isFalse);
    });

    test('should have correct helper properties when offline', () {
      // Arrange
      final state = OfflineModeState(
        status: OfflineModeStatus.offline,
        isLoggedIn: true,
        hasNetwork: false,
      );

      // Act & Assert
      expect(state.canPlayMusic, isFalse);
      expect(state.canSearch, isFalse);
      expect(state.canEditProfile, isFalse);
      expect(state.canCreatePlaylists, isFalse);
      expect(state.canDeletePlaylists, isFalse);
      expect(state.canAddRemoveSongs, isFalse);
      expect(state.canLoadImages, isFalse);
      expect(state.canRefreshData, isFalse);
      expect(state.hasLimitedAccess, isTrue);
      expect(state.isFullyOffline, isFalse);
    });

    test('should have correct helper properties when disconnected', () {
      // Arrange
      final state = OfflineModeState(
        status: OfflineModeStatus.disconnected,
        isLoggedIn: false,
        hasNetwork: false,
      );

      // Act & Assert
      expect(state.canPlayMusic, isFalse);
      expect(state.canSearch, isFalse);
      expect(state.canEditProfile, isFalse);
      expect(state.canCreatePlaylists, isFalse);
      expect(state.canDeletePlaylists, isFalse);
      expect(state.canAddRemoveSongs, isFalse);
      expect(state.canLoadImages, isFalse);
      expect(state.canRefreshData, isFalse);
      expect(state.hasLimitedAccess, isFalse);
      expect(state.isFullyOffline, isTrue);
    });

    test('should handle copyWith with null values correctly', () {
      // Arrange
      final originalState = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: true,
        hasNetwork: true,
      );

      // Act
      final newState = originalState.copyWith();

      // Assert
      expect(newState.status, equals(originalState.status));
      expect(newState.isLoggedIn, equals(originalState.isLoggedIn));
      expect(newState.hasNetwork, equals(originalState.hasNetwork));
    });

    test('should handle partial copyWith correctly', () {
      // Arrange
      final originalState = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: true,
        hasNetwork: true,
      );

      // Act
      final newState = originalState.copyWith(
        status: OfflineModeStatus.disconnected,
      );

      // Assert
      expect(newState.status, equals(OfflineModeStatus.disconnected));
      expect(newState.isLoggedIn, equals(originalState.isLoggedIn)); // Unchanged
      expect(newState.hasNetwork, equals(originalState.hasNetwork)); // Unchanged
    });
  });

  group('OfflineModeStatus', () {
    test('should have correct enum values', () {
      // Assert
      expect(OfflineModeStatus.online, isA<OfflineModeStatus>());
      expect(OfflineModeStatus.offline, isA<OfflineModeStatus>());
      expect(OfflineModeStatus.disconnected, isA<OfflineModeStatus>());
    });
  });
}

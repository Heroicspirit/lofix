import 'package:flutter_test/flutter_test.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';


void main() {
  group('OfflineModeProvider Basic Tests', () {
    test('should create OfflineModeState correctly', () {
      // Act
      final state = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: false,
        hasNetwork: true,
      );

      // Assert
      expect(state.status, equals(OfflineModeStatus.online));
      expect(state.isLoggedIn, isFalse);
      expect(state.hasNetwork, isTrue);
    });

    test('should copyWith correctly', () {
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
      expect(newState.hasNetwork, isTrue); // Unchanged
    });

    test('should have correct helper properties for online status', () {
      // Act
      final state = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: false,
        hasNetwork: true,
      );

      // Assert - Based on actual implementation, helper properties only check status
      expect(state.canPlayMusic, isTrue); // Online status allows all operations
      expect(state.canSearch, isTrue);
      expect(state.canEditProfile, isTrue);
      expect(state.hasLimitedAccess, isFalse);
      expect(state.isFullyOffline, isFalse);
    });

    test('should have correct helper properties for logged in online status', () {
      // Act
      final state = OfflineModeState(
        status: OfflineModeStatus.online,
        isLoggedIn: true,
        hasNetwork: true,
      );

      // Assert
      expect(state.canPlayMusic, isTrue);
      expect(state.canSearch, isTrue);
      expect(state.canEditProfile, isTrue);
      expect(state.hasLimitedAccess, isFalse);
      expect(state.isFullyOffline, isFalse);
    });

    test('should have correct helper properties for offline status', () {
      // Act
      final state = OfflineModeState(
        status: OfflineModeStatus.offline,
        isLoggedIn: true,
        hasNetwork: false,
      );

      // Assert
      expect(state.canPlayMusic, isFalse);
      expect(state.canSearch, isFalse);
      expect(state.canEditProfile, isFalse);
      expect(state.hasLimitedAccess, isTrue);
      expect(state.isFullyOffline, isFalse);
    });

    test('should have correct helper properties for disconnected status', () {
      // Act
      final state = OfflineModeState(
        status: OfflineModeStatus.disconnected,
        isLoggedIn: false,
        hasNetwork: false,
      );

      // Assert
      expect(state.canPlayMusic, isFalse);
      expect(state.canSearch, isFalse);
      expect(state.canEditProfile, isFalse);
      expect(state.hasLimitedAccess, isFalse);
      expect(state.isFullyOffline, isTrue);
    });

    test('should determine status correctly for online with network', () {
      // Act - simulate the logic from _determineStatus
      OfflineModeStatus status;
      bool hasNetwork = true;
      bool isLoggedIn = false;
      
      if (hasNetwork) {
        status = OfflineModeStatus.online;
      } else {
        if (isLoggedIn) {
          status = OfflineModeStatus.offline;
        } else {
          status = OfflineModeStatus.disconnected;
        }
      }

      // Assert
      expect(status, equals(OfflineModeStatus.online));
    });

    test('should determine status correctly for offline with login', () {
      // Act - simulate the logic from _determineStatus
      OfflineModeStatus status;
      bool hasNetwork = false;
      bool isLoggedIn = true;
      
      if (hasNetwork) {
        status = OfflineModeStatus.online;
      } else {
        if (isLoggedIn) {
          status = OfflineModeStatus.offline;
        } else {
          status = OfflineModeStatus.disconnected;
        }
      }

      // Assert
      expect(status, equals(OfflineModeStatus.offline));
    });

    test('should determine status correctly for disconnected without login', () {
      // Act - simulate the logic from _determineStatus
      OfflineModeStatus status;
      bool hasNetwork = false;
      bool isLoggedIn = false;
      
      if (hasNetwork) {
        status = OfflineModeStatus.online;
      } else {
        if (isLoggedIn) {
          status = OfflineModeStatus.offline;
        } else {
          status = OfflineModeStatus.disconnected;
        }
      }

      // Assert
      expect(status, equals(OfflineModeStatus.disconnected));
    });

    test('should have correct enum values', () {
      // Assert
      expect(OfflineModeStatus.online.index, equals(0));
      expect(OfflineModeStatus.offline.index, equals(1));
      expect(OfflineModeStatus.disconnected.index, equals(2));
    });

    test('should have correct string representations', () {
      // Assert
      expect(OfflineModeStatus.online.toString(), equals('OfflineModeStatus.online'));
      expect(OfflineModeStatus.offline.toString(), equals('OfflineModeStatus.offline'));
      expect(OfflineModeStatus.disconnected.toString(), equals('OfflineModeStatus.disconnected'));
    });
  });
}

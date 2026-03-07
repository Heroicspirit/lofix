import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';

void main() {
  group('OfflineModeProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with online status', () {
      // Act
      final state = container.read(offlineModeProvider);

      // Assert
      expect(state.status, equals(OfflineModeStatus.online));
      expect(state.isLoggedIn, isFalse);
      expect(state.hasNetwork, isTrue);
    });

    test('should update login status correctly', () {
      // Act
      container.read(offlineModeProvider.notifier).updateLoginStatus(true);
      final state = container.read(offlineModeProvider);

      // Assert
      expect(state.status, equals(OfflineModeStatus.online));
      expect(state.isLoggedIn, isTrue);
      expect(state.hasNetwork, isTrue);
    });

    test('should update login status to false', () {
      // Arrange
      container.read(offlineModeProvider.notifier).updateLoginStatus(true);

      // Act
      container.read(offlineModeProvider.notifier).updateLoginStatus(false);
      final state = container.read(offlineModeProvider);

      // Assert
      expect(state.status, equals(OfflineModeStatus.online));
      expect(state.isLoggedIn, isFalse);
      expect(state.hasNetwork, isTrue);
    });

    test('should handle multiple state changes', () {
      // Act & Assert
      expect(container.read(offlineModeProvider).isLoggedIn, isFalse);

      container.read(offlineModeProvider.notifier).updateLoginStatus(true);
      expect(container.read(offlineModeProvider).isLoggedIn, isTrue);

      container.read(offlineModeProvider.notifier).updateLoginStatus(false);
      expect(container.read(offlineModeProvider).isLoggedIn, isFalse);

      container.read(offlineModeProvider.notifier).updateLoginStatus(true);
      expect(container.read(offlineModeProvider).isLoggedIn, isTrue);
    });

    test('should maintain state consistency across reads', () {
      // Arrange
      container.read(offlineModeProvider.notifier).updateLoginStatus(true);

      // Act
      final firstRead = container.read(offlineModeProvider);
      final secondRead = container.read(offlineModeProvider);
      final thirdRead = container.read(offlineModeProvider);

      // Assert
      expect(firstRead.isLoggedIn, isTrue);
      expect(secondRead.isLoggedIn, isTrue);
      expect(thirdRead.isLoggedIn, isTrue);
    });

    test('should have correct helper properties when online', () {
      // Act
      final state = container.read(offlineModeProvider);

      // Assert
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
  });
}

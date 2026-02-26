import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/connectivity/network_info.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

// Offline mode state
enum OfflineModeStatus {
  online,     // Full functionality
  offline,     // Limited functionality for logged-in users
  disconnected // No access for logged-out users
}

// Offline mode provider
final offlineModeProvider = StateNotifierProvider<OfflineModeNotifier, OfflineModeState>((ref) {
  return OfflineModeNotifier(
    networkInfo: ref.read(networkInfoProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class OfflineModeState {
  final OfflineModeStatus status;
  final bool isLoggedIn;
  final bool hasNetwork;

  OfflineModeState({
    required this.status,
    required this.isLoggedIn,
    required this.hasNetwork,
  });

  OfflineModeState copyWith({
    OfflineModeStatus? status,
    bool? isLoggedIn,
    bool? hasNetwork,
  }) {
    return OfflineModeState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasNetwork: hasNetwork ?? this.hasNetwork,
    );
  }

  // Helper methods to check restrictions
  bool get canPlayMusic => status == OfflineModeStatus.online;
  bool get canSearch => status == OfflineModeStatus.online;
  bool get canEditProfile => status == OfflineModeStatus.online;
  bool get canCreatePlaylists => status == OfflineModeStatus.online;
  bool get canDeletePlaylists => status == OfflineModeStatus.online;
  bool get canAddRemoveSongs => status == OfflineModeStatus.online;
  bool get canLoadImages => status == OfflineModeStatus.online;
  bool get canRefreshData => status == OfflineModeStatus.online;
  bool get hasLimitedAccess => status == OfflineModeStatus.offline;
  bool get isFullyOffline => status == OfflineModeStatus.disconnected;
}

class OfflineModeNotifier extends StateNotifier<OfflineModeState> {
  final INetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  OfflineModeNotifier({
    required INetworkInfo networkInfo,
    required UserSessionService userSessionService,
  }) : _networkInfo = networkInfo,
       _userSessionService = userSessionService,
       super(OfflineModeState(
         status: OfflineModeStatus.online,
         isLoggedIn: false,
         hasNetwork: true,
       )) {
    _initialize();
  }

  Future<void> _initialize() async {
    await checkConnectionStatus();
  }

  Future<void> checkConnectionStatus() async {
    final hasNetwork = await _networkInfo.isConnected;
    final isLoggedIn = _userSessionService.isLoggedIn();

    final newStatus = _determineStatus(hasNetwork, isLoggedIn);

    state = state.copyWith(
      hasNetwork: hasNetwork,
      isLoggedIn: isLoggedIn,
      status: newStatus,
    );
  }

  OfflineModeStatus _determineStatus(bool hasNetwork, bool isLoggedIn) {
    if (hasNetwork) {
      return OfflineModeStatus.online;
    } else {
      if (isLoggedIn) {
        return OfflineModeStatus.offline; // Limited access for logged-in users
      } else {
        return OfflineModeStatus.disconnected; // No access for logged-out users
      }
    }
  }

  // Method to manually refresh connection status
  Future<void> refresh() async {
    await checkConnectionStatus();
  }

  // Method to update login status (called during login/logout)
  void updateLoginStatus(bool isLoggedIn) {
    final newStatus = _determineStatus(state.hasNetwork, isLoggedIn);
    state = state.copyWith(
      isLoggedIn: isLoggedIn,
      status: newStatus,
    );
  }
}

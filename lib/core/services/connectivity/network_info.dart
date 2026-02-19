
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);
  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }
}
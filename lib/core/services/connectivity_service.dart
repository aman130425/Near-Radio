import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Service for monitoring network connectivity.
/// When internet reconnects, triggers all registered refresh callbacks so data auto-refreshes.
class ConnectivityService extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectivityResult = ConnectivityResult.none.obs;
  final RxBool _wasOffline = false.obs;

  /// Callbacks to run when connectivity is restored (offline → online).
  final List<VoidCallback> _onReconnectedCallbacks = [];

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      final online = result != ConnectivityResult.none;
      connectivityResult.value = result;
      isConnected.value = online;
      _wasOffline.value = !online;
      Logger.info('Connectivity initialized: $online');
    } catch (e) {
      Logger.error('Failed to check connectivity', 'ConnectivityService', e);
      isConnected.value = false;
      _wasOffline.value = true;
    }
  }

  /// Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    final online = result != ConnectivityResult.none;
    final wasOffline = _wasOffline.value;

    connectivityResult.value = result;
    isConnected.value = online;
    _wasOffline.value = !online;

    /// When reconnected (was offline, now online) — trigger all refresh callbacks
    if (wasOffline && online) {
      Logger.info('Internet reconnected — triggering data refresh');
      for (final cb in _onReconnectedCallbacks) {
        try {
          cb();
        } catch (e) {
          Logger.error('Reconnect callback error', 'ConnectivityService', e);
        }
      }
    }
    Logger.info('Connectivity changed: $online');
  }

  /// Register a callback to run when internet reconnects. Use for auto-refreshing data.
  void onReconnected(VoidCallback callback) {
    if (!_onReconnectedCallbacks.contains(callback)) {
      _onReconnectedCallbacks.add(callback);
    }
  }

  /// Unregister a reconnect callback
  void removeOnReconnected(VoidCallback callback) {
    _onReconnectedCallbacks.remove(callback);
  }

  /// Manually re-check connectivity
  Future<void> checkNow() async {
    await _initConnectivity();
  }

  /// Check if device is online
  bool get isOnline => isConnected.value;

  /// Check if device is offline
  bool get isOffline => !isConnected.value;
}


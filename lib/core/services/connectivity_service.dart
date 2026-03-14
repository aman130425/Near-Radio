import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Service for monitoring network connectivity
class ConnectivityService extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectivityResult = ConnectivityResult.none.obs;

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
      connectivityResult.value = result;
      isConnected.value = result != ConnectivityResult.none;
      Logger.info('Connectivity initialized: ${isConnected.value}');
    } catch (e) {
      Logger.error('Failed to check connectivity', 'ConnectivityService', e);
      isConnected.value = false;
    }
  }

  /// Update connection status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    connectivityResult.value = result;
    isConnected.value = result != ConnectivityResult.none;
    Logger.info('Connectivity changed: ${isConnected.value}');
  }

  /// Check if device is online
  bool get isOnline => isConnected.value;

  /// Check if device is offline
  bool get isOffline => !isConnected.value;
}


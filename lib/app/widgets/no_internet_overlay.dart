import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/connectivity_service.dart';

/// Banner shown when there is no internet.
/// Uses Get.find<ConnectivityService>().isConnected.obs to reactively show/hide.
/// Displays "No Internet" with retry button.
class NoInternetOverlay extends StatelessWidget {
  const NoInternetOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Observe isConnected.obs so UI rebuilds when connectivity changes
      final isConnected = Get.find<ConnectivityService>().isConnected.value;
      if (isConnected) return const SizedBox.shrink();

      final connectivity = Get.find<ConnectivityService>();
      return Material(
        color: Theme.of(context).colorScheme.errorContainer,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.noInternet,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => connectivity.checkNow(),
                  child: Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

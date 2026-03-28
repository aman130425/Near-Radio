import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/connectivity_service.dart';
import 'no_internet_overlay.dart';

/// Wraps [child] with Stack: when ConnectivityService.isOffline, shows
/// [NoInternetOverlay] on top; when online shows child only.
/// Uses Obx to listen to connectivity changes.
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connectivity = Get.find<ConnectivityService>();
      final isOffline = connectivity.isOffline;

      return Stack(
        children: [
          child,
          if (isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const NoInternetOverlay(),
            ),
        ],
      );
    });
  }
}

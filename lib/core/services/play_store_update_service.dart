import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

/// Google Play [In-App Updates](https://developer.android.com/guide/playcore/in-app-updates).
/// Works for **internal / closed / open testing** installs from Play.
/// The `upgrader` package does not — it scrapes the **public** Play page only.
class PlayStoreUpdateService {
  PlayStoreUpdateService._();

  /// Call once when the main shell opens (e.g. [MainController.onInit]).
  static void checkAndPromptUpdate() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    unawaited(_run());
  }

  static Future<void> _run() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        if (info.installStatus == InstallStatus.downloaded) {
          await InAppUpdate.completeFlexibleUpdate();
        }
        return;
      }

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      if (!info.flexibleUpdateAllowed) return;

      late final StreamSubscription<InstallStatus> subscription;
      subscription = InAppUpdate.installUpdateListener.listen((status) async {
        if (status == InstallStatus.downloaded) {
          await subscription.cancel();
          try {
            await InAppUpdate.completeFlexibleUpdate();
          } catch (e) {
            if (kDebugMode) debugPrint('PlayStoreUpdateService completeFlexible: $e');
          }
        } else if (status == InstallStatus.failed ||
            status == InstallStatus.canceled) {
          await subscription.cancel();
        }
      });

      final result = await InAppUpdate.startFlexibleUpdate();
      if (result != AppUpdateResult.success) {
        await subscription.cancel();
      }
    } catch (e, st) {
      if (_isAppNotInstalledFromPlay(e)) {
        // ERROR_APP_NOT_OWNED (-10): `flutter run`, APK sideload, etc. — not an error.
        if (kDebugMode) {
          debugPrint(
            'PlayStoreUpdateService: in-app update unavailable (app not installed from Play).',
          );
        }
        return;
      }
      if (kDebugMode) {
        debugPrint('PlayStoreUpdateService: $e\n$st');
      }
    }
  }

  /// Play only allows in-app updates for installs acquired through Play.
  static bool _isAppNotInstalledFromPlay(Object error) {
    if (error is PlatformException) {
      final blob = '${error.code} ${error.message} ${error.details}';
      return blob.contains('-10') || blob.toLowerCase().contains('not owned');
    }
    final s = error.toString();
    return s.contains('-10') || s.toLowerCase().contains('not owned');
  }
}

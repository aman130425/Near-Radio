import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:near_radio/app/theme/app_theme.dart';
import 'package:near_radio/core/services/storage_service.dart';
import 'package:near_radio/core/services/analytics_service.dart';

/// Settings controller
class SettingsController extends GetxController {
  final AppTheme _appTheme = Get.find<AppTheme>();

  // Observables
  final RxBool notificationsEnabled = true.obs;

  /// `versionName (versionCode)` from the built app (see `pubspec.yaml` version).
  final RxString packageVersionLine = ''.obs;

  @override
  void onInit() {
    super.onInit();
    notificationsEnabled.value = StorageService.getNotificationPreference();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      packageVersionLine.value = '${info.version} (${info.buildNumber})';
    } catch (_) {
      packageVersionLine.value = '—';
    }
  }

  /// Toggle theme
  void toggleTheme() {
    _appTheme.toggleTheme();
  }

  /// Toggle notifications
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    StorageService.saveNotificationPreference(value);
    AnalyticsService.logNotificationPreference(enabled: value);
  }

  /// Get theme mode
  bool get isDarkMode => _appTheme.isDarkMode.value;
}

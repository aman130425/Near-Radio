import 'package:get/get.dart';
import 'package:near_radio/app/theme/app_theme.dart';
import 'package:near_radio/core/services/storage_service.dart';
import 'package:near_radio/core/constants/app_constants.dart';
import 'package:near_radio/core/services/analytics_service.dart';

/// Settings controller
class SettingsController extends GetxController {
  final AppTheme _appTheme = Get.find<AppTheme>();

  // Observables
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    notificationsEnabled.value = StorageService.getNotificationPreference();
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

  /// Get app version
  String get appVersion => AppConstants.appVersion;

  /// Get theme mode
  bool get isDarkMode => _appTheme.isDarkMode.value;
}

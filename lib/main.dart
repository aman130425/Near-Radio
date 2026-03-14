import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/bindings/initial_binding.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded<Future<void>>(() async {
    // Initialize Firebase only if not already done
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    // Pass all Flutter framework errors to Crashlytics (includes UI overflow/overlapping)
    FlutterError.onError = (errorDetails) {
      if (kDebugMode) FlutterError.presentError(errorDetails); // Show red screen in debug
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await PushNotificationService.instance.init();

    await StorageService.init();

    await initNotifications();

    InitialBinding().dependencies();

    // Get theme controller
    final appTheme = Get.find<AppTheme>();

    runApp(MyApp(appTheme: appTheme));
  }, (error, stackTrace) {
    // Catch all unhandled async errors (Dart zone errors)
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  final AppTheme appTheme;

  const MyApp({
    super.key,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      title: 'Near Radio',
      debugShowCheckedModeBanner: false,
      theme: appTheme.lightTheme,
      darkTheme: appTheme.darkTheme,
      themeMode: appTheme.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    ));
  }
}

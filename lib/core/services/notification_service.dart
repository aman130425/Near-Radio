import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_constants.dart';

final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

/// Initialize notifications for the app (Android 8+).
/// Creates the media notification channel so status bar / lock screen notification can show.
/// Call this once at app startup, before AudioService.
Future<void> initNotifications() async {
  if (!Platform.isAndroid) return;

  const androidSettings = AndroidInitializationSettings('mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await _plugin.initialize(initSettings);

  final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin == null) return;

  const channel = AndroidNotificationChannel(
    AppConstants.mediaNotificationChannelId,
    AppConstants.appName,
    description: 'Radio streaming playback',
    importance: Importance.high,
    playSound: false,
    showBadge: true,
  );
  await androidPlugin.createNotificationChannel(channel);

  const fcmChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Push Notifications',
    description: 'Firebase push notifications',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
  );
  await androidPlugin.createNotificationChannel(fcmChannel);

  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

/// Show a local notification (used for FCM foreground messages so user sees them on device).
Future<void> showFcmForegroundNotification({
  required String title,
  String? body,
  Map<String, dynamic>? data,
}) async {
  if (!Platform.isAndroid) return;

  const androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'Push Notifications',
    channelDescription: 'Firebase push notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    showWhen: true,
  );
  const details = NotificationDetails(android: androidDetails);

  final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
  await _plugin.show(
    id,
    title,
    body ?? '',
    details,
    payload: data != null && data.isNotEmpty ? data.toString() : null,
  );
}

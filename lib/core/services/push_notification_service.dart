import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

/// Handles Firebase Cloud Messaging (push notifications).
/// Call [init] from main.dart after Firebase.initializeApp().
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService _instance = PushNotificationService._();
  static PushNotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FCM token for this device (use for sending targeted notifications from server).
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Callback when a new FCM token is generated.
  void Function(String token)? onTokenRefresh;

  /// Callback when a notification is tapped (payload optional).
  void Function(Map<String, dynamic>? data)? onNotificationTap;

  /// Initialize FCM: permissions, token, foreground/background handlers.
  Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    await _requestPermission();

    // Foreground messages: show heads-up or handle in-app
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When user taps notification (app opened from terminated or background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Initial message that opened the app from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    await _refreshToken();
    _messaging.onTokenRefresh.listen((String token) {
      _fcmToken = token;
      onTokenRefresh?.call(token);
    });
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      print('FCM permission: ${settings.authorizationStatus}');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('FCM foreground: ${message.notification?.title}');
    }
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body;
    showFcmForegroundNotification(
      title: title,
      body: body,
      data: message.data.isNotEmpty ? message.data : null,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    if (data.isNotEmpty) {
      onNotificationTap?.call(data);
    } else {
      onNotificationTap?.call(null);
    }
  }

  Future<void> _refreshToken() async {
    try {
      _fcmToken = await _messaging.getToken(
        vapidKey: null, // Optional for web
      );
      if (kDebugMode && _fcmToken != null) {
        print('FCM token: $_fcmToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM getToken error: $e');
      }
    }
  }

  /// Subscribe to a topic (e.g. "news", "offers") for server-sent notifications.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

/// Top-level handler for background/terminated messages. Must be a top-level function.
/// When app is killed, this runs in a separate isolate – we init Firebase + show notification here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!Platform.isAndroid) return;

  await Firebase.initializeApp();

  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('mipmap/ic_launcher');
  await plugin.initialize(InitializationSettings(android: androidSettings));

  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Push Notifications',
      description: 'Firebase push notifications',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );
    await androidPlugin.createNotificationChannel(channel);

    final title = message.notification?.title ?? message.data['title'] ?? 'New message';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'Push Notifications',
        channelDescription: 'Firebase push notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        showWhen: true,
      ),
    );
    final id = message.hashCode.abs().remainder(100000);
    await plugin.show(id, title, body, details);
  }
}

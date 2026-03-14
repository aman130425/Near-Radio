import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Utility to log custom errors/keys to Firebase Crashlytics.
/// Use for non-fatal errors or to add context before a crash.
class CrashlyticsService {
  CrashlyticsService._();
  static final FirebaseCrashlytics _instance = FirebaseCrashlytics.instance;

  /// Log a non-fatal error (e.g. API failure, parse error).
  static Future<void> logError(
    Object error, [
    StackTrace? stackTrace,
    String? reason,
  ]) async {
    await _instance.log(reason ?? error.toString());
    await _instance.recordError(error, stackTrace, fatal: false);
  }

  /// Add a key-value for crash context (e.g. current screen, user action).
  static Future<void> setCustomKey(String key, Object value) async {
    await _instance.setCustomKey(key, value);
  }

  /// Set user identifier for grouping crashes by user.
  static Future<void> setUserId(String id) async {
    await _instance.setUserIdentifier(id);
  }

  /// Log a message (appears in crash report).
  static Future<void> log(String message) async {
    await _instance.log(message);
  }

  /// Record a non-fatal error with optional context.
  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (reason != null) await _instance.log(reason);
    await _instance.recordError(error, stackTrace, fatal: fatal);
  }
}

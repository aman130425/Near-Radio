import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
class Logger {
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      print('[${tag ?? 'DEBUG'}] $message');
    }
  }
  
  static void error(String message, [String? tag, dynamic error]) {
    if (kDebugMode) {
      print('[${tag ?? 'ERROR'}] $message');
      if (error != null) {
        print('Error details: $error');
      }
    }
  }
  
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      print('[${tag ?? 'INFO'}] $message');
    }
  }
}


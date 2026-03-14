/// Application-wide constants
class AppConstants {
  // Storage Keys
  static const String keyFavourites = 'favourites';
  static const String keyRecentStations = 'recent_stations';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications_enabled';
  
  // Audio Constants
  static const Duration audioTimeout = Duration(seconds: 30);
  /// Notification channel ID for media playback (must match notification_service.dart).
  static const String mediaNotificationChannelId = 'com.near_radio.audio';
  
  // App Info
  static const String appName = 'Near Radio';

  /// Bottom inset for main tab content (mini player + bottom nav bar). Content scrolls behind this.
  static const double mainViewBottomInset = 90;

  // Onboarding (first-time only)
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String appVersion = '1.0.0';
  
  // Categories
  static const List<String> categories = [
    'Pop',
    'Rock',
    'Jazz',
    'Classical',
    'Electronic',
    'Hip Hop',
    'Country',
    'News',
    'Sports',
    'Talk',
  ];
  
  // Countries
  static const List<String> countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'India',
    'Japan',
  ];
}


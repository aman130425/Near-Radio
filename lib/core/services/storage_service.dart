import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import '../models/radio_station.dart';
import '../utils/logger.dart';

/// Service for handling local storage operations
class StorageService {
  static final GetStorage _storage = GetStorage();

  /// Initialize storage
  static Future<void> init() async {
    try {
      await GetStorage.init();
      Logger.info('Storage initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize storage', 'StorageService', e);
    }
  }

  // Favourites Operations
  /// Save favourite station
  static Future<void> saveFavourite(RadioStation station) async {
    try {
      final favourites = getFavourites();
      if (!favourites.any((s) => s.id == station.id)) {
        favourites.add(station);
        await _storage.write(
          AppConstants.keyFavourites,
          favourites.map((s) => s.toJson()).toList(),
        );
        Logger.debug('Station saved to favourites: ${station.name}');
      }
    } catch (e) {
      Logger.error('Failed to save favourite', 'StorageService', e);
    }
  }

  /// Remove favourite station
  static Future<void> removeFavourite(String stationId) async {
    try {
      final favourites = getFavourites();
      favourites.removeWhere((s) => s.id == stationId);
      await _storage.write(
        AppConstants.keyFavourites,
        favourites.map((s) => s.toJson()).toList(),
      );
      Logger.debug('Station removed from favourites: $stationId');
    } catch (e) {
      Logger.error('Failed to remove favourite', 'StorageService', e);
    }
  }

  /// Get all favourite stations
  static List<RadioStation> getFavourites() {
    try {
      final data = _storage.read<List>(AppConstants.keyFavourites);
      if (data == null) return [];
      return data
          .map((json) => RadioStation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('Failed to get favourites', 'StorageService', e);
      return [];
    }
  }

  /// Check if station is favourite
  static bool isFavourite(String stationId) {
    return getFavourites().any((s) => s.id == stationId);
  }

  // Recent Stations Operations
  /// Save recent station
  static Future<void> saveRecentStation(RadioStation station) async {
    try {
      final recent = getRecentStations();
      // Remove if already exists
      recent.removeWhere((s) => s.id == station.id);
      // Add to beginning
      recent.insert(0, station.copyWith(lastPlayed: DateTime.now()));
      // Keep only last 20
      if (recent.length > 20) {
        recent.removeRange(20, recent.length);
      }
      await _storage.write(
        AppConstants.keyRecentStations,
        recent.map((s) => s.toJson()).toList(),
      );
      Logger.debug('Recent station saved: ${station.name}');
    } catch (e) {
      Logger.error('Failed to save recent station', 'StorageService', e);
    }
  }

  /// Get recent stations
  static List<RadioStation> getRecentStations() {
    try {
      final data = _storage.read<List>(AppConstants.keyRecentStations);
      if (data == null) return [];
      return data
          .map((json) => RadioStation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('Failed to get recent stations', 'StorageService', e);
      return [];
    }
  }

  // Settings Operations
  /// Save theme mode
  static Future<void> saveThemeMode(bool isDark) async {
    await _storage.write(AppConstants.keyThemeMode, isDark);
  }

  /// Get theme mode
  static bool getThemeMode() {
    return _storage.read<bool>(AppConstants.keyThemeMode) ?? true;
  }

  /// Save notification preference
  static Future<void> saveNotificationPreference(bool enabled) async {
    await _storage.write(AppConstants.keyNotifications, enabled);
  }

  /// Get notification preference
  static bool getNotificationPreference() {
    return _storage.read<bool>(AppConstants.keyNotifications) ?? true;
  }

  // Onboarding (first-time only)
  /// Mark onboarding as completed (called when user taps Get Started).
  static Future<void> setOnboardingCompleted() async {
    await _storage.write(AppConstants.keyOnboardingCompleted, true);
  }

  /// Whether user has seen onboarding (open main; else show onboarding).
  static bool hasSeenOnboarding() {
    return _storage.read<bool>(AppConstants.keyOnboardingCompleted) ?? false;
  }
}


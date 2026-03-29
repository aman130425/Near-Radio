import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:near_radio/core/analytics/analytics_events.dart';
import 'package:near_radio/core/analytics/analytics_screens.dart';
import 'package:near_radio/core/models/radio_station.dart';

/// Firebase Analytics: custom events + safe parameter shaping for GA4 limits.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Set false if [logEvent] hits an unrecoverable [PlatformException] on this run.
  static bool _nativeOk = true;

  /// Call after [Firebase.initializeApp].
  static Future<void> init() async {
    _nativeOk = true;
  }

  static String _clip(String? value, [int max = 100]) {
    if (value == null || value.isEmpty) return '';
    if (value.length <= max) return value;
    return value.substring(0, max);
  }

  static Map<String, Object> _onlyStrings(Map<String, Object?> map) {
    final out = <String, Object>{};
    for (final e in map.entries) {
      if (e.value == null) continue;
      final v = e.value!;
      if (v is String) {
        out[e.key] = _clip(v);
      } else if (v is num || v is bool) {
        out[e.key] = v;
      } else {
        out[e.key] = _clip(v.toString());
      }
      if (out.length >= 25) break;
    }
    return out;
  }

  static void _log(String name, Map<String, Object?> parameters) {
    if (!_nativeOk) return;
    final sanitized = _onlyStrings(parameters);
    final Future<void> future = sanitized.isEmpty
        ? _analytics.logEvent(name: name)
        : _analytics.logEvent(name: name, parameters: sanitized);
    future.catchError((Object e) {
      if (e is PlatformException && e.code == 'channel-error') {
        _nativeOk = false;
        if (kDebugMode) {
          debugPrint(
            'Firebase Analytics: channel-error — stop app, run `flutter clean` '
            'then `flutter run` (hot restart does not reload native plugins).',
          );
        }
      }
    });
  }

  // ——— Playback ———

  static void logPlayStation(RadioStation station, {required String screenName}) {
    _log(AnalyticsEvents.playStation, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.stationId: _clip(station.id, 36),
      AnalyticsParams.stationName: station.name,
    });
  }

  static void logPlayerNext(RadioStation station, {required String screenName}) {
    _log(AnalyticsEvents.playerNext, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.stationId: _clip(station.id, 36),
      AnalyticsParams.stationName: station.name,
    });
  }

  static void logPlayerPrevious(RadioStation station, {required String screenName}) {
    _log(AnalyticsEvents.playerPrevious, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.stationId: _clip(station.id, 36),
      AnalyticsParams.stationName: station.name,
    });
  }

  static void logLocalMusicPlay({required String musicName, required String screenName}) {
    _log(AnalyticsEvents.localMusicPlay, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.musicName: musicName,
    });
  }

  static void logPausePlayback({required String screenName}) {
    _log(AnalyticsEvents.pausePlayback, {
      AnalyticsParams.screenName: screenName,
    });
  }

  static void logResumePlayback({required String screenName}) {
    _log(AnalyticsEvents.resumePlayback, {
      AnalyticsParams.screenName: screenName,
    });
  }

  static void logPlaybackFailed(String message) {
    _log(AnalyticsEvents.playbackFailed, {
      AnalyticsParams.errorMessage: message,
    });
  }

  static void logMuteToggle({required bool isMuted, required String screenName}) {
    _log(AnalyticsEvents.muteToggle, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.isMuted: isMuted,
    });
  }

  // ——— Favourites ———

  static void logFavouriteAdded(RadioStation station, {required String screenName}) {
    _log(AnalyticsEvents.favouriteAdded, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.stationId: _clip(station.id, 36),
      AnalyticsParams.stationName: station.name,
    });
  }

  static void logFavouriteRemoved(RadioStation station, {required String screenName}) {
    _log(AnalyticsEvents.favouriteRemoved, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.stationId: _clip(station.id, 36),
      AnalyticsParams.stationName: station.name,
    });
  }

  static void logFavouriteRemovedById(String stationId, {required String screenName}) {
    _log(AnalyticsEvents.favouriteRemoved, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.stationId: _clip(stationId, 36),
    });
  }

  // ——— Browse / filters ———

  static void logFilterTabChanged(String tab, {required String screenName}) {
    _log(AnalyticsEvents.filterTabChanged, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.filterTab: _clip(tab, 32),
    });
  }

  static void logCountryNameSelected(String name, {required String screenName}) {
    _log(AnalyticsEvents.countryNameSelected, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.countryName: name,
    });
  }

  static void logLanguageNameSelected(String name, {required String screenName}) {
    _log(AnalyticsEvents.languageNameSelected, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.languageName: name,
    });
  }

  static void logGenreNameSelected(String name, {required String screenName}) {
    _log(AnalyticsEvents.genreNameSelected, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.genreName: name,
    });
  }

  static DateTime? _lastSearchLog;

  /// Throttled: avoids logging every keystroke. [searchTerm] is clipped (privacy).
  static void logSearchStations(String searchTerm, {required String screenName}) {
    final t = searchTerm.trim();
    if (t.isEmpty) return;
    final now = DateTime.now();
    if (_lastSearchLog != null &&
        now.difference(_lastSearchLog!) < const Duration(seconds: 2)) {
      return;
    }
    _lastSearchLog = now;
    _log(AnalyticsEvents.searchStations, {
      AnalyticsParams.screenName: screenName,
      AnalyticsParams.searchTerm: t,
    });
  }

  // ——— Onboarding & settings ———

  static void logOnboardingComplete() {
    _log(AnalyticsEvents.onboardingComplete, {
      AnalyticsParams.screenName: AnalyticsScreens.onboarding,
    });
  }

  static void logThemeChanged({required bool isDark}) {
    _log(AnalyticsEvents.themeChanged, {
      AnalyticsParams.screenName: AnalyticsScreens.settings,
      AnalyticsParams.isDarkMode: isDark,
    });
  }

  static void logNotificationPreference({required bool enabled}) {
    _log(AnalyticsEvents.notificationPrefChanged, {
      AnalyticsParams.screenName: AnalyticsScreens.settings,
      AnalyticsParams.notificationsEnabled: enabled,
    });
  }

  // ——— Push ———

  static void logPushNotificationOpened(Map<String, dynamic>? data) {
    final keys = data == null || data.isEmpty
        ? ''
        : _clip(data.keys.take(8).join(','), 100);
    _log(AnalyticsEvents.pushNotificationOpened, {
      AnalyticsParams.hasPayload: data != null && data.isNotEmpty,
      AnalyticsParams.payloadKeys: keys,
    });
  }

  // ——— API / content errors ———

  static void logHomeChannelsLoadFailed() {
    _log(AnalyticsEvents.homeChannelsLoadFailed, {
      AnalyticsParams.screenName: AnalyticsScreens.home,
    });
  }

  static void logStationListFiltersLoadFailed() {
    _log(AnalyticsEvents.stationListFiltersLoadFailed, {
      AnalyticsParams.screenName: AnalyticsScreens.stationList,
    });
  }

  static void logStationListLoadFailed() {
    _log(AnalyticsEvents.stationListLoadFailed, {
      AnalyticsParams.screenName: AnalyticsScreens.stationList,
    });
  }

  static void logLoadMoreChannels() {
    _log(AnalyticsEvents.loadMoreChannels, {
      AnalyticsParams.screenName: AnalyticsScreens.home,
    });
  }

  static void logLoadMoreStations() {
    _log(AnalyticsEvents.loadMoreStations, {
      AnalyticsParams.screenName: AnalyticsScreens.stationList,
    });
  }

  @visibleForTesting
  static FirebaseAnalytics get analytics => _analytics;
}

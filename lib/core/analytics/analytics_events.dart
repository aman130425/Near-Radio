/// Firebase / GA4 custom event names (≤40 chars, [a-z0-9_]).
abstract final class AnalyticsEvents {
  static const playStation = 'play_station';
  static const playerNext = 'player_next';
  static const playerPrevious = 'player_previous';
  static const localMusicPlay = 'local_music_play';

  static const pausePlayback = 'pause_playback';
  static const resumePlayback = 'resume_playback';
  static const playbackFailed = 'playback_failed';

  static const muteToggle = 'mute_toggle';

  static const favouriteAdded = 'favourite_added';
  static const favouriteRemoved = 'favourite_removed';

  static const filterTabChanged = 'filter_tab_changed';

  /// User picked a country row (name shown in analytics).
  static const countryNameSelected = 'country_name_selected';
  static const languageNameSelected = 'language_name_selected';
  static const genreNameSelected = 'genre_name_selected';

  /// User typed in station / filter search (includes search text + screen).
  static const searchStations = 'search_stations';

  static const onboardingComplete = 'onboarding_complete';

  static const themeChanged = 'theme_changed';
  static const notificationPrefChanged = 'notification_pref_changed';

  static const pushNotificationOpened = 'push_notification_opened';

  static const homeChannelsLoadFailed = 'home_channels_load_failed';
  static const stationListFiltersLoadFailed = 'station_list_filters_load_failed';
  static const stationListLoadFailed = 'station_list_load_failed';

  static const loadMoreChannels = 'load_more_channels';
  static const loadMoreStations = 'load_more_stations';
}

/// Parameter keys (≤40 chars). Values must be ≤100 chars for strings.
abstract final class AnalyticsParams {
  static const screenName = 'screen_name';
  static const stationId = 'station_id';
  static const stationName = 'station_name';
  static const musicName = 'music_name';
  static const searchTerm = 'search_term';
  static const countryName = 'country_name';
  static const languageName = 'language_name';
  static const genreName = 'genre_name';
  static const errorMessage = 'error_message';

  static const filterTab = 'filter_tab';
  static const isMuted = 'is_muted';

  static const isDarkMode = 'is_dark_mode';
  static const notificationsEnabled = 'notifications_enabled';

  static const hasPayload = 'has_payload';
  static const payloadKeys = 'payload_keys';
}

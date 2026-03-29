/// Human-readable screen labels for Firebase Analytics (not controller class names).
abstract final class AnalyticsScreens {
  static const splash = 'Splash';
  static const onboarding = 'Onboarding';
  static const main = 'Main';
  static const home = 'Home';
  static const stationList = 'Station List';
  static const favourites = 'Favourites';
  static const localMusic = 'Local Music';
  static const settings = 'Settings';
  static const player = 'Player';
  static const miniPlayer = 'Mini Player';
}

/// How a play action should be logged (separate events for next / previous / local file).
enum PlayAnalyticsAction {
  /// Normal station play (event: [AnalyticsEvents.playStation]).
  play,

  /// Player screen next button (event: [AnalyticsEvents.playerNext]).
  next,

  /// Player screen previous button (event: [AnalyticsEvents.playerPrevious]).
  previous,

  /// Local music file play (event: [AnalyticsEvents.localMusicPlay]).
  localMusic,
}

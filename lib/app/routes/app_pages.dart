import 'package:get/get.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/onboarding/onboarding_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/station_list/station_list_view.dart';
import '../../modules/favourites/favourites_view.dart';
import '../../modules/local_music/local_music_view.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/main/main_view.dart';
import '../../modules/player/player_view.dart';
import '../bindings/initial_binding.dart';

/// Application routes
class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.stationList,
      page: () => const StationListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.favourites,
      page: () => const FavouritesView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.local,
      page: () => const LocalMusicView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.player,
      page: () => const PlayerView(),
      binding: InitialBinding(),
    ),
  ];
}

/// Route names
class Routes {
  Routes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const main = '/main';
  static const home = '/home';
  static const stationList = '/station-list';
  static const favourites = '/favourites';
  static const local = '/local';
  static const settings = '/settings';
  static const player = '/player';
}


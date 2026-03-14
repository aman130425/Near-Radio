import 'package:get/get.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/connectivity_service.dart';
import '../theme/app_theme.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/onboarding_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/station_list_controller.dart';
import '../../controllers/favourites_controller.dart';
import '../../controllers/local_music_controller.dart';
import '../../controllers/player_controller.dart';

/// Initial binding for global services and all controllers
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Theme and services
    Get.put(AppTheme(), permanent: true);
    Get.put(AudioService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);

    // Controllers (lazy so they are created when first used)
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<StationListController>(() => StationListController());
    Get.lazyPut<FavouritesController>(() => FavouritesController());
    Get.lazyPut<LocalMusicController>(() => LocalMusicController());
    Get.lazyPut<PlayerController>(() => PlayerController());
  }
}


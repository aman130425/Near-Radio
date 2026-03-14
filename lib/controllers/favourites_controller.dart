import 'package:get/get.dart';
import 'package:near_radio/app/routes/app_pages.dart';
import 'package:near_radio/core/models/radio_station.dart';
import 'package:near_radio/core/services/storage_service.dart';
import 'package:near_radio/core/services/audio_service.dart';
import 'package:near_radio/core/constants/app_strings.dart';
import 'package:near_radio/controllers/player_controller.dart';

/// Favourites controller
class FavouritesController extends GetxController {
  final RxList<RadioStation> favouriteStations = <RadioStation>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavourites();
  }

  @override
  void onReady() {
    super.onReady();
    loadFavourites();
  }

  void loadFavourites() {
    favouriteStations.value = StorageService.getFavourites();
  }

  Future<void> removeFavourite(RadioStation station) async {
    await StorageService.removeFavourite(station.id);
    loadFavourites();
    Get.snackbar(AppStrings.removeFromFavourites, 'Removed from favourites', snackPosition: SnackPosition.TOP);
  }

  Future<void> playStation(RadioStation station) async {
    try {
      PlayerController playerController;
      if (Get.isRegistered<PlayerController>()) {
        playerController = Get.find<PlayerController>();
      } else {
        playerController = Get.put(PlayerController(), permanent: false);
        await Future.delayed(const Duration(milliseconds: 100));
      }
      playerController.setStationList(favouriteStations, station);
      playerController.currentStation.value = station;
      Get.toNamed(Routes.player);
      await playerController.playStation(station);
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Failed to play station: ${e.toString()}', snackPosition: SnackPosition.TOP);
    }
  }

  bool isCurrentlyPlaying(RadioStation station) {
    final audioService = Get.find<AudioService>();
    return audioService.currentStation.value?.id == station.id && audioService.isPlaying.value;
  }

  Future<void> togglePlayPause(RadioStation station) async {
    if (isCurrentlyPlaying(station)) {
      await Get.toNamed(Routes.player);
      Get.find<PlayerController>().setStationList(favouriteStations, station);
    } else {
      await playStation(station);
    }
  }
}

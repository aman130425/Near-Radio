import 'package:get/get.dart';
import 'package:near_radio/core/models/radio_station.dart';
import 'package:near_radio/core/services/audio_service.dart';
import 'package:near_radio/core/services/storage_service.dart';
import 'package:near_radio/core/constants/app_strings.dart';
import 'package:near_radio/controllers/favourites_controller.dart';
import 'package:near_radio/core/analytics/analytics_screens.dart';
import 'package:near_radio/core/services/analytics_service.dart';

/// Player screen controller
class PlayerController extends GetxController {
  final AudioService _audioService = Get.find<AudioService>();

  // Observables
  final Rx<RadioStation?> currentStation = Rx<RadioStation?>(null);
  final RxList<RadioStation> stationList = <RadioStation>[].obs;
  final RxInt currentIndex = (-1).obs;
  final RxBool isLoading = false.obs;
  final RxBool isPlaying = false.obs;
  final RxList<RadioStation> recentStations = <RadioStation>[].obs;
  /// Tracks favourite state for current station so UI updates immediately on toggle
  final RxBool isCurrentStationFavourite = false.obs;

  @override
  void onInit() {
    super.onInit();
    _audioService.currentStation.listen((station) {
      currentStation.value = station;
      _updateCurrentIndex();
    });
    _audioService.isPlaying.listen((playing) => isPlaying.value = playing);
    _audioService.isLoading.listen((loading) => isLoading.value = loading);
  }

  @override
  void onReady() {
    super.onReady();
    currentStation.value = _audioService.currentStation.value;
    _updateCurrentIndex();
    _updateFavouriteState();
    _loadRecentStations();
    _audioService.currentStation.listen((station) {
      if (station != null) {
        currentStation.value = station;
        _updateCurrentIndex();
        _updateFavouriteState();
      }
    });
  }

  void _loadRecentStations() {
    recentStations.value = StorageService.getRecentStations();
  }

  void _updateCurrentIndex() {
    if (currentStation.value != null && stationList.isNotEmpty) {
      final index = stationList.indexWhere((s) => s.id == currentStation.value!.id);
      if (index >= 0) {
        currentIndex.value = index;
      } else {
        final indexByName = stationList.indexWhere((s) => s.name == currentStation.value!.name);
        currentIndex.value = indexByName >= 0 ? indexByName : -1;
      }
    } else {
      currentIndex.value = -1;
    }
  }

  void setStationList(List<RadioStation> stations, RadioStation current) {
    if (stations.isEmpty) {
      stationList.clear();
      currentIndex.value = -1;
      _updateFavouriteState();
      return;
    }
    stationList.value = stations;
    currentStation.value = current;
    _updateCurrentIndex();
    _updateFavouriteState();
    if (currentIndex.value < 0 && stations.isNotEmpty) {
      final index = stations.indexWhere((s) => s.id == current.id);
      if (index >= 0) currentIndex.value = index;
    }
  }

  void _updateFavouriteState() {
    final station = currentStation.value;
    isCurrentStationFavourite.value = station != null && StorageService.isFavourite(station.id);
  }

  bool get hasPreviousStation =>
      stationList.isNotEmpty && currentIndex.value > 0;

  bool get hasNextStation =>
      stationList.isNotEmpty &&
      currentIndex.value >= 0 &&
      currentIndex.value < stationList.length - 1;

  Future<void> playPrevious() async {
    if (currentIndex.value <= 0 || stationList.isEmpty) return;
    final previousIndex = currentIndex.value - 1;
    if (previousIndex >= 0 && previousIndex < stationList.length) {
      currentIndex.value = previousIndex;
      await playStation(
        stationList[previousIndex],
        screenName: AnalyticsScreens.player,
        action: PlayAnalyticsAction.previous,
      );
    }
  }

  Future<void> playNext() async {
    if (stationList.isEmpty || currentIndex.value < 0 || currentIndex.value >= stationList.length - 1) return;
    final nextIndex = currentIndex.value + 1;
    if (nextIndex < stationList.length) {
      currentIndex.value = nextIndex;
      await playStation(
        stationList[nextIndex],
        screenName: AnalyticsScreens.player,
        action: PlayAnalyticsAction.next,
      );
    }
  }

  Future<void> playStation(
    RadioStation station, {
    String screenName = AnalyticsScreens.player,
    PlayAnalyticsAction action = PlayAnalyticsAction.play,
  }) async {
    try {
      isLoading.value = true;
      currentStation.value = station;
      _updateCurrentIndex();
      _updateFavouriteState();
      await _audioService.playStation(station, screenName: screenName, action: action);
      await Future.delayed(const Duration(milliseconds: 100));
      await StorageService.saveRecentStation(station);
      _loadRecentStations();
      isLoading.value = false;
      if (stationList.isNotEmpty && currentIndex.value >= 0) {
        Get.snackbar(AppStrings.playing, station.name, snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(AppStrings.error, 'Failed to play station: ${e.toString()}', snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> togglePlayPause() async {
    if (currentStation.value == null) return;
    if (isPlaying.value) {
      AnalyticsService.logPausePlayback(screenName: AnalyticsScreens.player);
      await _audioService.pause();
    } else {
      AnalyticsService.logResumePlayback(screenName: AnalyticsScreens.player);
      await _audioService.resume();
    }
  }

  Future<void> toggleFavourite(RadioStation station) async {
    if (StorageService.isFavourite(station.id)) {
      await StorageService.removeFavourite(station.id);
      isCurrentStationFavourite.value = false;
      AnalyticsService.logFavouriteRemoved(station, screenName: AnalyticsScreens.player);
      Get.snackbar(AppStrings.removeFromFavourites, 'Removed from favourites', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
    } else {
      await StorageService.saveFavourite(station);
      isCurrentStationFavourite.value = true;
      AnalyticsService.logFavouriteAdded(station, screenName: AnalyticsScreens.player);
      Get.snackbar(AppStrings.addToFavourites, 'Added to favourites', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
    }
    _refreshFavouritesController();
  }

  void _refreshFavouritesController() {
    try {
      if (Get.isRegistered<FavouritesController>()) {
        Get.find<FavouritesController>().loadFavourites();
      }
    } catch (_) {}
  }

  bool isFavourite(RadioStation station) => StorageService.isFavourite(station.id);

  bool get isMuted => _audioService.isMuted.value;

  Future<void> toggleMute() async {
    await _audioService.toggleMute();
    AnalyticsService.logMuteToggle(
      isMuted: _audioService.isMuted.value,
      screenName: AnalyticsScreens.player,
    );
  }
}

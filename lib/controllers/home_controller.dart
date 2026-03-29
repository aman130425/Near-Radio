import 'package:get/get.dart';
import 'package:near_radio/app/routes/app_pages.dart';
import 'package:near_radio/core/constants/app_constants.dart';
import 'package:near_radio/core/models/radio_station.dart';
import 'package:near_radio/core/services/radio_api_service.dart';
import 'package:near_radio/core/services/storage_service.dart';
import 'package:near_radio/core/services/audio_service.dart';
import 'package:near_radio/core/services/connectivity_service.dart';
import 'package:near_radio/core/constants/app_strings.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'package:near_radio/controllers/favourites_controller.dart';
import 'package:near_radio/core/analytics/analytics_screens.dart';
import 'package:near_radio/core/services/analytics_service.dart';

/// Home screen controller – All channels from API with pagination
class HomeController extends GetxController {
  final RadioApiService _apiService = RadioApiService();
  final AudioService _audioService = Get.find<AudioService>();

  /// Top 20 English channels (horizontal scroll, above All channels)
  final RxList<RadioStation> topEnglishChannels = <RadioStation>[].obs;
  /// Top stations by user's location (below Top English, same style)
  final RxList<RadioStation> topLocalStations = <RadioStation>[].obs;
  /// All channels (first 72 on load, more on "See more")
  final RxList<RadioStation> allChannels = <RadioStation>[].obs;
  final RxList<RadioStation> recentStations = <RadioStation>[].obs;
  static const int _englishLanguageId = 2;
  final RxBool hasMoreChannels = true.obs;
  final RxBool isLoadingMore = false.obs;
  int _currentPage = 1;
  static const int _perPage = 72;

  final RxList<String> categories = RxList<String>(AppConstants.categories);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Get.find<ConnectivityService>().onReconnected(loadData);
    loadData();
  }

  Future<void> loadData() async {
    if (!Get.find<ConnectivityService>().isOnline) {
      errorMessage.value = AppStrings.noInternet;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    _currentPage = 1;
    try {
      final topEnglishFuture = _apiService.fetchStationsByFilter(
        filterType: 'language',
        id: _englishLanguageId,
        page: 1,
        perPage: 20,
      );
      final topLocalFuture = _apiService.fetchTopStationsByLocation(limit: 20);
      final allChannelsFuture = _apiService.fetchStationsPage(
        page: _currentPage,
        perPage: _perPage,
      );
      final topEnglishResult = await topEnglishFuture;
      final topLocal = await topLocalFuture;
      final allResult = await allChannelsFuture;
      topEnglishChannels.value = topEnglishResult.stations;
      topLocalStations.value = topLocal;
      allChannels.value = allResult.stations;
      hasMoreChannels.value = allResult.hasMore;
      recentStations.value = StorageService.getRecentStations();
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Unable to load channels. Please check your connection.';
      topEnglishChannels.value = [];
      topLocalStations.value = [];
      allChannels.value = [];
      hasMoreChannels.value = false;
      AnalyticsService.logHomeChannelsLoadFailed();
    }
    isLoading.value = false;
  }

  Future<void> loadMoreChannels() async {
    if (!hasMoreChannels.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      _currentPage += 1;
      final result = await _apiService.fetchStationsPage(
        page: _currentPage,
        perPage: _perPage,
      );
      allChannels.addAll(result.stations);
      hasMoreChannels.value = result.hasMore;
      AnalyticsService.logLoadMoreChannels();
    } catch (_) {
      hasMoreChannels.value = false;
    }
    isLoadingMore.value = false;
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
      final combined = [...recentStations, ...topEnglishChannels, ...topLocalStations, ...allChannels];
      playerController.setStationList(combined, station);
      playerController.currentStation.value = station;
      Get.toNamed(Routes.player);
      await playerController.playStation(station, screenName: AnalyticsScreens.home);
      recentStations.value = StorageService.getRecentStations();
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Failed to play station: ${e.toString()}', snackPosition: SnackPosition.TOP);
    }
  }

  bool isCurrentlyPlaying(RadioStation station) {
    return _audioService.currentStation.value?.id == station.id && _audioService.isPlaying.value;
  }

  Future<void> togglePlayPause(RadioStation station) async {
    if (isCurrentlyPlaying(station)) {
      await Get.toNamed(Routes.player);
      final playerController = Get.find<PlayerController>();
      final combined = [...recentStations, ...topEnglishChannels, ...topLocalStations, ...allChannels];
      playerController.setStationList(combined, station);
    } else {
      await playStation(station);
    }
  }

  Future<void> toggleFavourite(RadioStation station) async {
    if (StorageService.isFavourite(station.id)) {
      await StorageService.removeFavourite(station.id);
      AnalyticsService.logFavouriteRemoved(station, screenName: AnalyticsScreens.home);
      Get.snackbar(AppStrings.removeFromFavourites, 'Removed from favourites', snackPosition: SnackPosition.TOP);
    } else {
      await StorageService.saveFavourite(station);
      AnalyticsService.logFavouriteAdded(station, screenName: AnalyticsScreens.home);
      Get.snackbar(AppStrings.addToFavourites, 'Added to favourites', snackPosition: SnackPosition.TOP);
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
}

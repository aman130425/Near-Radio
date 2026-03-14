import 'package:get/get.dart';
import 'package:near_radio/core/models/radio_station.dart';
import 'package:near_radio/core/models/filter_api_models.dart';
import 'package:near_radio/core/services/radio_api_service.dart';
import 'package:near_radio/core/services/storage_service.dart';
import 'package:near_radio/core/services/audio_service.dart';
import 'package:near_radio/core/constants/app_strings.dart';
import 'package:near_radio/app/routes/app_pages.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'package:near_radio/controllers/favourites_controller.dart';

/// Filter type enum
enum FilterType { default_, aToZ, zToA, number }

/// Tab type enum
enum TabType { country, genre, language }

/// Item with count model (id used for API when loading stations)
class ItemWithCount {
  final int id;
  final String name;
  final int count;
  ItemWithCount({required this.id, required this.name, required this.count});
}

/// Station list controller
class StationListController extends GetxController {
  final RadioApiService _apiService = RadioApiService();

  final RxList<RadioStation> allStations = <RadioStation>[].obs;
  final RxList<RadioStation> filteredStations = <RadioStation>[].obs;
  final RxList<dynamic> displayList = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<TabType> selectedTab = TabType.country.obs;
  final Rx<FilterType> selectedFilter = FilterType.default_.obs;
  final RxString selectedItem = ''.obs;
  final RxInt selectedItemId = 0.obs;

  final RxBool hasMoreFilteredStations = false.obs;
  final RxBool isLoadingMoreFiltered = false.obs;
  int _filteredStationsPage = 1;

  final RxList<ItemWithCount> countriesWithCount = <ItemWithCount>[].obs;
  final RxList<ItemWithCount> genresWithCount = <ItemWithCount>[].obs;
  final RxList<ItemWithCount> languagesWithCount = <ItemWithCount>[].obs;

  /// Total from API meta (for display)
  final RxInt totalCountries = 0.obs;
  final RxInt totalCategories = 0.obs;
  final RxInt totalLanguages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFilterData();
  }

  /// Load countries, categories, languages from API; build name + station count
  Future<void> loadFilterData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final countriesFuture = _apiService.fetchAllCountries();
      final categoriesFuture = _apiService.fetchAllCategories();
      final languagesFuture = _apiService.fetchAllLanguages();

      final countriesResult = await countriesFuture;
      final categoriesResult = await categoriesFuture;
      final languagesResult = await languagesFuture;

      totalCountries.value = countriesResult.total;
      totalCategories.value = categoriesResult.total;
      totalLanguages.value = languagesResult.total;

      _buildListsWithCountsFromApi(
        countries: countriesResult.list,
        categories: categoriesResult.list,
        languages: languagesResult.list,
      );
      _updateDisplayList();
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Failed to load: ${e.toString()}';
      countriesWithCount.value = [];
      genresWithCount.value = [];
      languagesWithCount.value = [];
    }
    isLoading.value = false;
  }

  void _buildListsWithCountsFromApi({
    required List<CountryApiItem> countries,
    required List<CategoryApiItem> categories,
    required List<LanguageApiItem> languages,
  }) {
    countriesWithCount.value = countries
        .where((c) => c.radioStationsCount > 0)
        .map((c) => ItemWithCount(id: c.id, name: c.name, count: c.radioStationsCount))
        .toList();
    final countryList = List<ItemWithCount>.from(countriesWithCount);
    countryList.sort((a, b) => b.count.compareTo(a.count));
    countriesWithCount.value = countryList;

    genresWithCount.value = categories
        .where((c) => c.radioStationsCount > 0)
        .map((c) => ItemWithCount(id: c.id, name: c.name, count: c.radioStationsCount))
        .toList();
    final genreList = List<ItemWithCount>.from(genresWithCount);
    genreList.sort((a, b) => b.count.compareTo(a.count));
    genresWithCount.value = genreList;

    languagesWithCount.value = languages
        .where((l) => l.radioStationsCount > 0)
        .map((l) => ItemWithCount(id: l.id, name: l.name, count: l.radioStationsCount))
        .toList();
    final languageList = List<ItemWithCount>.from(languagesWithCount);
    languageList.sort((a, b) => b.count.compareTo(a.count));
    languagesWithCount.value = languageList;
  }

  /// Retry / refresh (used by view)
  Future<void> loadStations() => loadFilterData();

  /// Call from Home: switch to Radio tab with this country selected and show its stations
  void openWithCountry(String countryName) {
    selectedTab.value = TabType.country;
    ItemWithCount? item;
    for (var c in countriesWithCount) {
      if (c.name == countryName) { item = c; break; }
    }
    if (item != null) selectItem(item);
  }

  /// Call from Home: switch to Radio tab with this language selected and show its stations
  void openWithLanguage(String languageName) {
    selectedTab.value = TabType.language;
    ItemWithCount? item;
    for (var l in languagesWithCount) {
      if (l.name == languageName) { item = l; break; }
    }
    if (item != null) selectItem(item);
  }

  void selectTab(TabType tab) {
    selectedTab.value = tab;
    selectedItem.value = '';
    selectedItemId.value = 0;
    _updateDisplayList();
  }

  /// Select filter item and load stations from API
  Future<void> selectItem(ItemWithCount item) async {
    selectedItem.value = item.name;
    selectedItemId.value = item.id;
    await loadStationsForFilter();
  }

  void goBack() {
    selectedItem.value = '';
    selectedItemId.value = 0;
    _updateDisplayList();
  }

  final RxBool isLoadingFilteredStations = false.obs;

  String _filterTypeForTab(TabType tab) {
    switch (tab) {
      case TabType.country:
        return 'country';
      case TabType.genre:
        return 'category';
      case TabType.language:
        return 'language';
    }
  }

  /// Load stations for selected country/category/language from API
  Future<void> loadStationsForFilter() async {
    if (selectedItemId.value <= 0) return;
    isLoadingFilteredStations.value = true;
    _filteredStationsPage = 1;
    try {
      final filterType = _filterTypeForTab(selectedTab.value);
      final result = await _apiService.fetchStationsByFilter(
        filterType: filterType,
        id: selectedItemId.value,
        page: 1,
        perPage: 15,
      );
      filteredStations.value = result.stations;
      hasMoreFilteredStations.value = result.hasMore;
      displayList.value = List<RadioStation>.from(filteredStations);
    } catch (e) {
      filteredStations.value = [];
      displayList.value = [];
      hasMoreFilteredStations.value = false;
      errorMessage.value = 'Failed to load stations: ${e.toString()}';
    }
    isLoadingFilteredStations.value = false;
  }

  /// Load more stations (pagination)
  Future<void> loadMoreFilteredStations() async {
    if (!hasMoreFilteredStations.value || isLoadingMoreFiltered.value) return;
    isLoadingMoreFiltered.value = true;
    _filteredStationsPage += 1;
    try {
      final filterType = _filterTypeForTab(selectedTab.value);
      final result = await _apiService.fetchStationsByFilter(
        filterType: filterType,
        id: selectedItemId.value,
        page: _filteredStationsPage,
        perPage: 15,
      );
      filteredStations.addAll(result.stations);
      hasMoreFilteredStations.value = result.hasMore;
      displayList.value = List<RadioStation>.from(filteredStations);
    } catch (_) {
      hasMoreFilteredStations.value = false;
    }
    isLoadingMoreFiltered.value = false;
  }

  void setFilter(FilterType filter) {
    selectedFilter.value = filter;
    _updateDisplayList();
  }

  void searchStations(String query) {
    searchQuery.value = query;
    _updateDisplayList();
  }

  void _updateDisplayList() {
    if (selectedItem.value.isEmpty) {
      List<ItemWithCount> items = [];
      switch (selectedTab.value) {
        case TabType.country:
          items = List.from(countriesWithCount);
          break;
        case TabType.genre:
          items = List.from(genresWithCount);
          break;
        case TabType.language:
          items = List.from(languagesWithCount);
          break;
      }
      if (searchQuery.value.isNotEmpty) {
        items = items.where((item) => item.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
      }
      items = _applySortFilter(items);
      displayList.value = items;
    } else {
      // Filter stations (from API) by search query and apply sort
      List<RadioStation> filtered = List.from(filteredStations);
      if (searchQuery.value.isNotEmpty) {
        filtered = filtered.where((s) => s.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
      }
      filtered = _applySortFilter(filtered);
      displayList.value = filtered;
    }
  }

  List<T> _applySortFilter<T>(List<T> items) {
    if (items.isEmpty) return items;
    final List<T> sortedItems = List.from(items);
    switch (selectedFilter.value) {
      case FilterType.default_:
        return sortedItems;
      case FilterType.aToZ:
        if (sortedItems.first is ItemWithCount) {
          (sortedItems as List<ItemWithCount>).sort((a, b) => a.name.compareTo(b.name));
        } else if (sortedItems.first is RadioStation) {
          (sortedItems as List<RadioStation>).sort((a, b) => a.name.compareTo(b.name));
        }
        return sortedItems;
      case FilterType.zToA:
        if (sortedItems.first is ItemWithCount) {
          (sortedItems as List<ItemWithCount>).sort((a, b) => b.name.compareTo(a.name));
        } else if (sortedItems.first is RadioStation) {
          (sortedItems as List<RadioStation>).sort((a, b) => b.name.compareTo(a.name));
        }
        return sortedItems;
      case FilterType.number:
        if (sortedItems.first is ItemWithCount) {
          (sortedItems as List<ItemWithCount>).sort((a, b) => b.count.compareTo(a.count));
        } else if (sortedItems.first is RadioStation) {
          (sortedItems as List<RadioStation>).sort((a, b) => a.name.length.compareTo(b.name.length));
        }
        return sortedItems;
    }
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
      playerController.setStationList(filteredStations, station);
      playerController.currentStation.value = station;
      Get.toNamed(Routes.player);
      await playerController.playStation(station);
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Failed to play station: ${e.toString()}', snackPosition: SnackPosition.TOP);
    }
  }

  bool isCurrentlyPlaying(RadioStation station) {
    return Get.find<AudioService>().currentStation.value?.id == station.id && Get.find<AudioService>().isPlaying.value;
  }

  Future<void> toggleFavourite(RadioStation station) async {
    if (StorageService.isFavourite(station.id)) {
      await StorageService.removeFavourite(station.id);
      Get.snackbar(AppStrings.removeFromFavourites, 'Removed from favourites', snackPosition: SnackPosition.TOP);
    } else {
      await StorageService.saveFavourite(station);
      Get.snackbar(AppStrings.addToFavourites, 'Added to favourites', snackPosition: SnackPosition.TOP);
    }
    try {
      if (Get.isRegistered<FavouritesController>()) {
        Get.find<FavouritesController>().loadFavourites();
      }
    } catch (_) {}
  }

  bool isFavourite(RadioStation station) => StorageService.isFavourite(station.id);
}

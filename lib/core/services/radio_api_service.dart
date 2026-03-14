import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/radio_station.dart';
import '../models/station_api_models.dart';
import '../models/filter_api_models.dart';
import '../utils/logger.dart';

/// Service for fetching radio stations and filter data from Near Radio API
class RadioApiService {
  /// Fetch one page of stations
  /// Returns [stations] and [hasMore] for pagination
  Future<({List<RadioStation> stations, bool hasMore})> fetchStationsPage({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.stationsEndpoint}',
      ).replace(queryParameters: {
        'per_page': perPage.toString(),
        'page': page.toString(),
      });

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        Logger.error('Stations API error: ${response.statusCode}');
        return (stations: <RadioStation>[], hasMore: false);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = StationApiResponse.fromJson(json);

      if (!apiResponse.success || apiResponse.data.isEmpty) {
        return (
          stations: _mapToRadioStations(apiResponse.data),
          hasMore: false,
        );
      }

      final hasMore = apiResponse.meta != null &&
          apiResponse.meta!.currentPage < apiResponse.meta!.lastPage;

      return (
        stations: _mapToRadioStations(apiResponse.data),
        hasMore: hasMore,
      );
    } catch (e) {
      Logger.error('Failed to fetch stations', 'RadioApiService', e);
      return (stations: <RadioStation>[], hasMore: false);
    }
  }

  List<RadioStation> _mapToRadioStations(List<StationApiItem> items) {
    return items
        .where((item) => item.streamUrl.isNotEmpty)
        .map((item) => RadioStation(
              id: item.id.toString(),
              name: item.name,
              url: item.streamUrl,
              country: item.country?.name,
              category: item.category?.name,
              language: item.language?.name,
              logo: item.logo,
            ))
        .toList();
  }

  /// Fetch stations (first page only, for backward compatibility e.g. station list)
  Future<List<RadioStation>> fetchStations({
    String? country,
    String? category,
    String? search,
    int limit = 100,
  }) async {
    final perPage = limit.clamp(1, 100);
    final result = await fetchStationsPage(page: 1, perPage: perPage);
    return result.stations;
  }

  /// Fetch all countries (all pages)
  Future<({List<CountryApiItem> list, int total})> fetchAllCountries() async {
    final list = <CountryApiItem>[];
    var page = 1;
    var total = 0;
    try {
      while (true) {
        final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.countriesEndpoint}')
            .replace(queryParameters: {'per_page': '50', 'page': page.toString()});
        final response = await http.get(url, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Request timeout'));
        if (response.statusCode != 200) break;
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final res = CountryApiResponse.fromJson(json);
        if (!res.success || res.data.isEmpty) break;
        list.addAll(res.data);
        if (res.meta != null) total = res.meta!.total;
        if (res.meta == null || page >= res.meta!.lastPage) break;
        page++;
      }
      return (list: list, total: total);
    } catch (e) {
      Logger.error('Failed to fetch countries', 'RadioApiService', e);
      return (list: list, total: total);
    }
  }

  /// Fetch all categories (genre) – single request, API returns all
  Future<({List<CategoryApiItem> list, int total})> fetchAllCategories() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}');
      final response = await http.get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Request timeout'));
      if (response.statusCode != 200) return (list: <CategoryApiItem>[], total: 0);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final res = CategoryApiResponse.fromJson(json);
      final total = res.meta?.total ?? res.data.length;
      return (list: res.data, total: total);
    } catch (e) {
      Logger.error('Failed to fetch categories', 'RadioApiService', e);
      return (list: <CategoryApiItem>[], total: 0);
    }
  }

  /// Fetch stations by country ID
  /// {{base_url}}/api/stations/country/{id}?per_page=15&page=1
  Future<({List<RadioStation> stations, bool hasMore})> fetchStationsByCountry(
    int countryId, {
    int page = 1,
    int perPage = 15,
  }) async {
    return _fetchStationsByFilter(
      '${ApiConstants.stationsByCountryPath}/$countryId',
      page: page,
      perPage: perPage,
    );
  }

  /// Fetch stations by category (genre) ID
  /// {{base_url}}/api/stations/category/{id}?per_page=15&page=1
  Future<({List<RadioStation> stations, bool hasMore})> fetchStationsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 15,
  }) async {
    return _fetchStationsByFilter(
      '${ApiConstants.stationsByCategoryPath}/$categoryId',
      page: page,
      perPage: perPage,
    );
  }

  /// Fetch stations by language ID
  /// {{base_url}}/api/stations/language/{id}?per_page=15&page=1
  Future<({List<RadioStation> stations, bool hasMore})> fetchStationsByLanguage(
    int languageId, {
    int page = 1,
    int perPage = 15,
  }) async {
    return _fetchStationsByFilter(
      '${ApiConstants.stationsByLanguagePath}/$languageId',
      page: page,
      perPage: perPage,
    );
  }

  /// Fetch stations by filter (country/category/language). [filterType] = 'country'|'category'|'language'
  Future<({List<RadioStation> stations, bool hasMore})> fetchStationsByFilter({
    required String filterType,
    required int id,
    required int page,
    required int perPage,
  }) async {
    switch (filterType) {
      case 'country':
        return fetchStationsByCountry(id, page: page, perPage: perPage);
      case 'category':
        return fetchStationsByCategory(id, page: page, perPage: perPage);
      case 'language':
        return fetchStationsByLanguage(id, page: page, perPage: perPage);
      default:
        return (stations: <RadioStation>[], hasMore: false);
    }
  }

  Future<({List<RadioStation> stations, bool hasMore})> _fetchStationsByFilter(
    String path, {
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$path').replace(
        queryParameters: {
          'per_page': perPage.toString(),
          'page': page.toString(),
        },
      );
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );
      if (response.statusCode != 200) {
        Logger.error('Stations filter API error: ${response.statusCode}');
        return (stations: <RadioStation>[], hasMore: false);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = StationApiResponse.fromJson(json);
      final stations = _mapToRadioStations(apiResponse.data);
      final hasMore = apiResponse.meta != null &&
          apiResponse.meta!.currentPage < apiResponse.meta!.lastPage;
      return (stations: stations, hasMore: hasMore);
    } catch (e) {
      Logger.error('Failed to fetch stations by filter', 'RadioApiService', e);
      return (stations: <RadioStation>[], hasMore: false);
    }
  }

  /// Get user's public IP (for location-based APIs). Returns null on failure.
  Future<String?> _getPublicIp() async {
    try {
      final res = await http.get(Uri.parse('https://api.ipify.org'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        return res.body.trim();
      }
    } catch (_) {}
    return null;
  }

  /// Fetch top stations by user's location (local stations)
  /// {{base_url}}/api/stations/top-by-location?limit=20&ip=<user_ip>
  Future<List<RadioStation>> fetchTopStationsByLocation({int limit = 20}) async {
    try {
      final ip = await _getPublicIp();
      final queryParams = <String, String>{'limit': limit.toString()};
      if (ip != null && ip.isNotEmpty) queryParams['ip'] = ip;

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.stationsTopByLocationPath}')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );
      if (response.statusCode != 200) {
        Logger.error('Top by location API error: ${response.statusCode}');
        return [];
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = StationApiResponse.fromJson(json);
      return _mapToRadioStations(apiResponse.data);
    } catch (e) {
      Logger.error('Failed to fetch top stations by location', 'RadioApiService', e);
      return [];
    }
  }

  /// Fetch all languages (all pages)
  Future<({List<LanguageApiItem> list, int total})> fetchAllLanguages() async {
    final list = <LanguageApiItem>[];
    var page = 1;
    var total = 0;
    try {
      while (true) {
        final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.languagesEndpoint}')
            .replace(queryParameters: {'per_page': '50', 'page': page.toString()});
        final response = await http.get(url, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Request timeout'));
        if (response.statusCode != 200) break;
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final res = LanguageApiResponse.fromJson(json);
        if (!res.success || res.data.isEmpty) break;
        list.addAll(res.data);
        if (res.meta != null) total = res.meta!.total;
        if (res.meta == null || page >= res.meta!.lastPage) break;
        page++;
      }
      return (list: list, total: total);
    } catch (e) {
      Logger.error('Failed to fetch languages', 'RadioApiService', e);
      return (list: list, total: total);
    }
  }
}

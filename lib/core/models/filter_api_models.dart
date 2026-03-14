/// API response models for Countries, Categories, and Languages (filter lists)

import 'station_api_models.dart';

List<String> _parseMessage(dynamic message) {
  if (message is List) return message.map((e) => e.toString()).toList();
  if (message is String) return [message];
  return [];
}

int _readInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  return int.tryParse(v.toString()) ?? 0;
}

// ----- Countries -----

class CountryApiResponse {
  final bool success;
  final List<String> message;
  final List<CountryApiItem> data;
  final StationApiMeta? meta;
  final StationApiLinks? links;

  CountryApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
    this.links,
  });

  factory CountryApiResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return CountryApiResponse(
      success: json['success'] as bool? ?? false,
      message: _parseMessage(json['message']),
      data: dataList
          .map((e) => CountryApiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? StationApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      links: json['links'] != null
          ? StationApiLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CountryApiItem {
  final int id;
  final String name;
  final String? code;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final int radioStationsCount;

  CountryApiItem({
    required this.id,
    required this.name,
    this.code,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.radioStationsCount = 0,
  });

  factory CountryApiItem.fromJson(Map<String, dynamic> json) {
    return CountryApiItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      radioStationsCount: _readInt(json['radio_stations_count']),
    );
  }
}

// ----- Categories (Genre) -----

class CategoryApiResponse {
  final bool success;
  final List<String> message;
  final List<CategoryApiItem> data;
  final StationApiMeta? meta;
  final StationApiLinks? links;

  CategoryApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
    this.links,
  });

  factory CategoryApiResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return CategoryApiResponse(
      success: json['success'] as bool? ?? false,
      message: _parseMessage(json['message']),
      data: dataList
          .map((e) => CategoryApiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? StationApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      links: json['links'] != null
          ? StationApiLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CategoryApiItem {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final int radioStationsCount;

  CategoryApiItem({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.radioStationsCount = 0,
  });

  factory CategoryApiItem.fromJson(Map<String, dynamic> json) {
    return CategoryApiItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      radioStationsCount: _readInt(json['radio_stations_count']),
    );
  }
}

// ----- Languages -----

class LanguageApiResponse {
  final bool success;
  final List<String> message;
  final List<LanguageApiItem> data;
  final StationApiMeta? meta;
  final StationApiLinks? links;

  LanguageApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
    this.links,
  });

  factory LanguageApiResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return LanguageApiResponse(
      success: json['success'] as bool? ?? false,
      message: _parseMessage(json['message']),
      data: dataList
          .map((e) => LanguageApiItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? StationApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      links: json['links'] != null
          ? StationApiLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LanguageApiItem {
  final int id;
  final String name;
  final String? code;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final int radioStationsCount;

  LanguageApiItem({
    required this.id,
    required this.name,
    this.code,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.radioStationsCount = 0,
  });

  factory LanguageApiItem.fromJson(Map<String, dynamic> json) {
    return LanguageApiItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      radioStationsCount: _readInt(json['radio_stations_count']),
    );
  }
}

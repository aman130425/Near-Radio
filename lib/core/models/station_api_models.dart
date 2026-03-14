/// API response models for Near Radio stations API

class StationApiResponse {
  final bool success;
  final List<String> message;
  final List<StationApiItem> data;
  final StationApiMeta? meta;
  final StationApiLinks? links;

  StationApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
    this.links,
  });

  factory StationApiResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return StationApiResponse(
      success: json['success'] as bool? ?? false,
      message: (json['message'] is List)
          ? (json['message'] as List).map((e) => e.toString()).toList()
          : [],
      data: dataList
          .map((e) => StationApiItem.fromJson(e as Map<String, dynamic>))
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

class StationApiItem {
  final int id;
  final String name;
  final String streamUrl;
  final int? countryId;
  final String? state;
  final int? languageId;
  final int? categoryId;
  final String? description;
  final String? logo;
  final bool isActive;
  final bool isFeatured;
  final String? popularityScore;
  final int? playCount;
  final String? geoLat;
  final String? geoLong;
  final int? likeCount;
  final int? commentCount;
  final String? createdAt;
  final String? updatedAt;
  final StationCountry? country;
  final StationCategory? category;
  final StationLanguage? language;
  final List<StationTag> tags;

  StationApiItem({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.countryId,
    this.state,
    this.languageId,
    this.categoryId,
    this.description,
    this.logo,
    this.isActive = true,
    this.isFeatured = false,
    this.popularityScore,
    this.playCount,
    this.geoLat,
    this.geoLong,
    this.likeCount,
    this.commentCount,
    this.createdAt,
    this.updatedAt,
    this.country,
    this.category,
    this.language,
    this.tags = const [],
  });

  factory StationApiItem.fromJson(Map<String, dynamic> json) {
    final tagsList = json['tags'] as List<dynamic>? ?? [];
    return StationApiItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      streamUrl: json['stream_url'] as String? ?? '',
      countryId: json['country_id'] as int?,
      state: json['state'] as String?,
      languageId: json['language_id'] as int?,
      categoryId: json['category_id'] as int?,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      popularityScore: json['popularity_score']?.toString(),
      playCount: json['play_count'] as int?,
      geoLat: json['geo_lat']?.toString(),
      geoLong: json['geo_long']?.toString(),
      likeCount: json['like_count'] as int?,
      commentCount: json['comment_count'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      country: json['country'] != null
          ? StationCountry.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? StationCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      language: json['language'] != null
          ? StationLanguage.fromJson(json['language'] as Map<String, dynamic>)
          : null,
      tags: tagsList
          .map((e) => StationTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StationCountry {
  final int id;
  final String name;
  final String? code;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  StationCountry({
    required this.id,
    required this.name,
    this.code,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StationCountry.fromJson(Map<String, dynamic> json) {
    return StationCountry(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class StationCategory {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  StationCategory({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StationCategory.fromJson(Map<String, dynamic> json) {
    return StationCategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class StationLanguage {
  final int id;
  final String name;
  final String? code;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  StationLanguage({
    required this.id,
    required this.name,
    this.code,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StationLanguage.fromJson(Map<String, dynamic> json) {
    return StationLanguage(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class StationTag {
  final int id;
  final String name;
  final String? slug;
  final String? createdAt;
  final String? updatedAt;

  StationTag({
    required this.id,
    required this.name,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory StationTag.fromJson(Map<String, dynamic> json) {
    return StationTag(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class StationApiMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  StationApiMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory StationApiMeta.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic v) {
      if (v is int) return v;
      if (v is List && v.isNotEmpty) return int.tryParse(v.first.toString()) ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }
    return StationApiMeta(
      currentPage: readInt(json['current_page']),
      perPage: readInt(json['per_page']),
      total: readInt(json['total']),
      lastPage: readInt(json['last_page']),
      from: readInt(json['from']),
      to: readInt(json['to']),
    );
  }
}

class StationApiLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  StationApiLinks({this.first, this.last, this.prev, this.next});

  factory StationApiLinks.fromJson(Map<String, dynamic> json) {
    return StationApiLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

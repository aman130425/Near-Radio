/// Radio Station model
class RadioStation {
  final String id;
  final String name;
  final String url;
  final String? country;
  final String? category;
  final String? language;
  final String? logo;
  final int? bitrate;
  final String? codec;
  final bool isPlaying;
  final DateTime? lastPlayed;

  RadioStation({
    required this.id,
    required this.name,
    required this.url,
    this.country,
    this.category,
    this.language,
    this.logo,
    this.bitrate,
    this.codec,
    this.isPlaying = false,
    this.lastPlayed,
  });

  /// Create RadioStation from JSON
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] ?? json['stationuuid'] ?? '',
      name: json['name'] ?? 'Unknown Station',
      url: json['url'] ?? json['url_resolved'] ?? '',
      country: json['country'] ?? json['countrycode'],
      category: json['tags'] ?? json['genre'],
      language: json['language'],
      logo: json['favicon'] ?? json['logo'],
      bitrate: json['bitrate'] is int ? json['bitrate'] : null,
      codec: json['codec'],
    );
  }

  /// Convert RadioStation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'country': country,
      'category': category,
      'language': language,
      'logo': logo,
      'bitrate': bitrate,
      'codec': codec,
      'isPlaying': isPlaying,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  RadioStation copyWith({
    String? id,
    String? name,
    String? url,
    String? country,
    String? category,
    String? language,
    String? logo,
    int? bitrate,
    String? codec,
    bool? isPlaying,
    DateTime? lastPlayed,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      country: country ?? this.country,
      category: category ?? this.category,
      language: language ?? this.language,
      logo: logo ?? this.logo,
      bitrate: bitrate ?? this.bitrate,
      codec: codec ?? this.codec,
      isPlaying: isPlaying ?? this.isPlaying,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadioStation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


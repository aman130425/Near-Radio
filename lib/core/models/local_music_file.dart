/// Local music file model
class LocalMusicFile {
  final String id;
  final String name;
  final String path;
  final String? artist;
  final String? album;
  final int? duration; // in milliseconds
  final String? artworkPath;

  LocalMusicFile({
    required this.id,
    required this.name,
    required this.path,
    this.artist,
    this.album,
    this.duration,
    this.artworkPath,
  });

  /// Create from file path
  factory LocalMusicFile.fromPath(String path) {
    final fileName = path.split('/').last;
    final nameWithoutExt = fileName.split('.').first;
    
    return LocalMusicFile(
      id: path,
      name: nameWithoutExt,
      path: path,
    );
  }

  /// Convert to RadioStation for compatibility with player
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': path,
      'artist': artist,
      'album': album,
      'duration': duration,
    };
  }
}


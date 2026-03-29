import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:near_radio/core/models/local_music_file.dart';
import 'package:near_radio/core/models/radio_station.dart';
import 'package:near_radio/app/routes/app_pages.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'package:near_radio/core/services/audio_service.dart';
import 'package:near_radio/core/constants/app_strings.dart';
import 'package:near_radio/core/analytics/analytics_screens.dart';
import 'package:near_radio/core/services/analytics_service.dart';

/// Local music controller – scans device storage for all audio (MP3, M4A, etc.).
class LocalMusicController extends GetxController {
  final AudioService _audioService = Get.find<AudioService>();

  final RxList<LocalMusicFile> localMusicFiles = <LocalMusicFile>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalMusic();
  }

  Future<void> loadLocalMusic() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        localMusicFiles.clear();
        errorMessage.value = Platform.isAndroid
            ? 'Device storage permission is required to show local music. Grant "Music and audio" or "All files" in Settings.'
            : 'Device storage permission is required to show local music.';
        isLoading.value = false;
        return;
      }

      errorMessage.value = '';
      final files = await _scanMusicFiles();
      localMusicFiles.value = files;
      if (files.isEmpty && Platform.isAndroid) {
        errorMessage.value =
            'No music found in common folders. Grant "All files" in Settings to scan full storage, or add songs using +.';
      } else if (files.isNotEmpty) {
        errorMessage.value = '';
      }
    } catch (e) {
      print('Error loading music: $e');
      localMusicFiles.clear();
      errorMessage.value = 'Could not load music. Try again or add songs using +.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openAppSettingsForPermission() async {
    await openAppSettings();
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) {
      try {
        final s = await Permission.storage.status;
        if (s.isGranted) return true;
        final r = await Permission.storage.request();
        return r.isGranted;
      } catch (_) {
        return false;
      }
    }

    try {
      if (await _checkStoragePermission()) return true;

      final audioResult = await Permission.audio.request();
      if (audioResult.isGranted) return true;

      final storageResult = await Permission.storage.request();
      if (storageResult.isGranted) return true;

      final manageResult = await Permission.manageExternalStorage.request();
      if (manageResult.isGranted) return true;

      return false;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  Future<bool> _checkStoragePermission() async {
    if (!Platform.isAndroid) {
      try {
        return (await Permission.storage.status).isGranted;
      } catch (_) {
        return false;
      }
    }

    try {
      if ((await Permission.audio.status).isGranted) return true;
      if ((await Permission.storage.status).isGranted) return true;
      if ((await Permission.manageExternalStorage.status).isGranted) return true;
      return false;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  Future<List<LocalMusicFile>> _scanMusicFiles() async {
    final List<LocalMusicFile> musicFiles = [];
    final Set<String> seenPaths = {};

    try {
      bool hasPermission = await _checkStoragePermission();
      if (!hasPermission) return musicFiles;

      final audioExtensions = ['.mp3', '.m4a', '.aac', '.wav', '.flac', '.ogg', '.wma', '.mp4'];
      final dirsToScan = await _getStorageRootsAndMusicDirs();

      for (var dir in dirsToScan) {
        try {
          if (await dir.exists()) {
            await _scanDirectory(dir, audioExtensions, musicFiles, seenPaths);
          }
        } catch (e) {
          print('Error scanning ${dir.path}: $e');
        }
      }
    } catch (e) {
      print('Error scanning directories: $e');
    }

    return musicFiles;
  }

  Future<List<Directory>> _getStorageRootsAndMusicDirs() async {
    final List<Directory> out = [];
    final Set<String> added = {};

    const commonFolders = [
      'Music',
      'Download',
      'Downloads',
      'DCIM',
      'Documents',
      'Recordings',
      'Ringtones',
      'Audiobooks',
      'Notifications',
      'Alarms',
      'Movies',
      'Media',
    ];

    void addDir(String path) {
      if (path.isEmpty || added.contains(path)) return;
      added.add(path);
      out.add(Directory(path));
    }

    if (Platform.isAndroid) {
      // Don't scan root /storage/emulated/0 - it hits Android/data and causes permission denied on Android 11+.
      // Only scan known music-friendly subfolders.
      const primaryRoot = '/storage/emulated/0';
      for (final name in commonFolders) {
        addDir('$primaryRoot/$name');
      }

      try {
        final dirs = await getExternalStorageDirectories();
        if (dirs != null) {
          for (final d in dirs) {
            final root = _externalStorageRoot(d.path);
            if (root != null && root != primaryRoot) {
              for (final name in commonFolders) {
                final path = '$root/$name';
                if (!added.contains(path)) addDir(path);
              }
            }
          }
        }
      } catch (_) {}

      try {
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          addDir(appDir.path);
          addDir('${appDir.path}/Music');
        }
      } catch (_) {}
    } else if (Platform.isIOS) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        addDir(appDir.path);
        final libDir = await getLibraryDirectory();
        addDir(libDir.path);
      } catch (_) {}
    } else {
      try {
        final dir = await getApplicationDocumentsDirectory();
        addDir(dir.path);
      } catch (_) {}
    }

    return out;
  }

  String? _externalStorageRoot(String appPath) {
    final segments = appPath.split(RegExp(r'[/\\]'));
    int i = segments.indexOf('Android');
    if (i > 0) {
      return segments.take(i).join('/');
    }
    i = segments.indexOf('emulated');
    if (i >= 0 && i + 1 < segments.length) {
      return segments.take(i + 2).join('/');
    }
    return null;
  }

  Future<void> _scanDirectory(
    Directory directory,
    List<String> extensions,
    List<LocalMusicFile> musicFiles,
    Set<String> seenPaths,
  ) async {
    try {
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          final path = entity.path;
          final pathLower = path.toLowerCase();
          if (extensions.any((ext) => pathLower.endsWith(ext.toLowerCase())) && !seenPaths.contains(path)) {
            seenPaths.add(path);
            musicFiles.add(LocalMusicFile.fromPath(path));
          }
        }
      }
    } catch (e) {
      print('Error scanning directory ${directory.path}: $e');
    }
  }

  Future<void> pickMusicFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg', 'wma'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files
            .where((file) => file.path != null)
            .map((file) => LocalMusicFile.fromPath(file.path!))
            .toList();

        for (var file in newFiles) {
          if (!localMusicFiles.any((f) => f.path == file.path)) {
            localMusicFiles.add(file);
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to pick files: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void searchMusic(String query) {
    searchQuery.value = query;
    AnalyticsService.logSearchStations(query, screenName: AnalyticsScreens.localMusic);
  }

  List<LocalMusicFile> get filteredMusicFiles {
    if (searchQuery.value.isEmpty) {
      return localMusicFiles;
    }
    return localMusicFiles
        .where((file) =>
            file.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  Future<void> playMusicFile(LocalMusicFile musicFile) async {
    try {
      final station = RadioStation(
        id: musicFile.id,
        name: musicFile.name,
        url: musicFile.path,
        category: musicFile.artist,
        country: musicFile.album,
      );

      PlayerController playerController;
      if (Get.isRegistered<PlayerController>()) {
        playerController = Get.find<PlayerController>();
      } else {
        playerController = Get.put(PlayerController(), permanent: false);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      playerController.setStationList([station], station);
      playerController.currentStation.value = station;

      Get.toNamed(Routes.player);

      await playerController.playStation(
        station,
        screenName: AnalyticsScreens.localMusic,
        action: PlayAnalyticsAction.localMusic,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        'Failed to play music: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  bool isCurrentlyPlaying(LocalMusicFile musicFile) {
    return _audioService.currentStation.value?.id == musicFile.id &&
           _audioService.isPlaying.value;
  }
}

import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:permission_handler/permission_handler.dart';
import '../models/radio_station.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'background_audio_handler.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'package:near_radio/core/analytics/analytics_screens.dart';
import 'package:near_radio/core/services/analytics_service.dart';
import 'package:near_radio/core/services/crashlytics_service.dart';

/// Service for handling audio playback
class AudioService extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  audio_service.AudioHandler? _audioHandler;
  
  // Observables
  final Rx<RadioStation?> currentStation = Rx<RadioStation?>(null);
  PlayerState get playerState => _audioPlayer.playerState;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Duration?> position = Rx<Duration?>(null);
  final Rx<Duration?> duration = Rx<Duration?>(null);
  final RxBool isMuted = false.obs;
  double _savedVolumeBeforeMute = 1.0;

  @override
  void onInit() {
    super.onInit();
    _initAudioService();
    _initAudioPlayer();
  }

  /// Ensure notification permission (Android 13+) so media notification can show
  Future<void> _ensureNotificationPermission() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  /// Initialize audio service for background playback
  Future<void> _initAudioService() async {
    try {
      _audioHandler = await audio_service.AudioService.init(
        builder: () => BackgroundAudioHandler(
          audioService: this,
          player: _audioPlayer,
        ),
        config: audio_service.AudioServiceConfig(
          androidNotificationChannelId: AppConstants.mediaNotificationChannelId,
          androidNotificationChannelName: AppConstants.appName,
          androidNotificationChannelDescription: 'Radio streaming playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
        ),
      );
      Logger.debug('Audio service initialized');
    } catch (e) {
      Logger.error('Failed to initialize audio service', 'AudioService', e);
    }
  }

  /// Initialize audio player
  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isLoading.value = state.processingState == ProcessingState.loading;
      
      if (state.processingState == ProcessingState.loading) {
        Logger.debug('Audio loading...');
      } else if (state.processingState == ProcessingState.ready) {
        Logger.debug('Audio ready');
        errorMessage.value = '';
      } else if (state.processingState == ProcessingState.buffering) {
        Logger.debug('Audio buffering...');
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      position.value = pos;
    });

    _audioPlayer.durationStream.listen((dur) {
      duration.value = dur;
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        Logger.debug('Audio playback completed');
      }
    });

    // Listen to player errors
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle && 
          state.playing == false && 
          currentStation.value != null) {
        // Check if there was an error
        _audioPlayer.playbackEventStream.listen((event) {
          // Error handling is done in playStation catch block
        }, onError: (error) {
          errorMessage.value = 'Playback error. Please try another station.';
          isLoading.value = false;
          Logger.error('Playback error', 'AudioService', error);
        });
      }
    });

    // Error handling for loading timeout
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading) {
        // Check for errors after a timeout
        Future.delayed(AppConstants.audioTimeout, () {
          if (isLoading.value && currentStation.value != null) {
            errorMessage.value = 'Connection timeout. Please try again.';
            isLoading.value = false;
            Logger.error('Audio loading timeout');
          }
        });
      }
    });
  }

  /// Play a radio station. [screenName] / [action] drive Firebase custom events.
  Future<void> playStation(
    RadioStation station, {
    required String screenName,
    PlayAnalyticsAction action = PlayAnalyticsAction.play,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _ensureNotificationPermission();
      
      // If same station is already loaded and paused, just resume
      if (currentStation.value != null &&
          currentStation.value!.id == station.id &&
          _audioPlayer.processingState != ProcessingState.idle &&
          !_audioPlayer.playing) {
        currentStation.value = station;
        if (_audioHandler != null) {
          await (_audioHandler as BackgroundAudioHandler).play();
        } else {
          await _audioPlayer.play();
        }
        isLoading.value = false;
        Logger.info('Resuming station: ${station.name}');
        AnalyticsService.logResumePlayback(screenName: screenName);
        return;
      }
      
      // Stop current playback if any (whether playing or paused) and it's a different station
      if (currentStation.value != null && currentStation.value!.id != station.id) {
        try {
          Logger.debug('Stopping previous station: ${currentStation.value!.name}');
          
          // Stop background handler first if available
          if (_audioHandler != null) {
            try {
              await (_audioHandler as BackgroundAudioHandler).stop();
              Logger.debug('Background handler stopped');
            } catch (e) {
              Logger.debug('Error stopping background handler: $e');
            }
          }
          
          // Pause first if playing
          if (_audioPlayer.playing) {
            await _audioPlayer.pause();
            Logger.debug('Audio player paused');
            await Future.delayed(const Duration(milliseconds: 100));
          }
          
          // Stop the player completely
          await _audioPlayer.stop();
          Logger.debug('Audio player stopped');
          
          // Wait for stop to complete and resources to be released
          await Future.delayed(const Duration(milliseconds: 200));
          
          Logger.debug('Previous station stopped, ready for new station');
        } catch (e) {
          Logger.error('Error stopping previous station', 'AudioService', e);
          // Even if stop fails, try to continue with new station
        }
      }

      // Decide if we need to load URL BEFORE updating currentStation (callers may set it early).
      // We must setUrl when: different station, or player is idle (no source loaded).
      final needToLoadUrl = currentStation.value?.id != station.id ||
          _audioPlayer.processingState == ProcessingState.idle;

      currentStation.value = station;

      // Update notification media item only; playback uses this single _audioPlayer
      if (_audioHandler != null) {
        try {
          (_audioHandler as BackgroundAudioHandler).setNotificationMediaFromStation(station);
        } catch (e) {
          Logger.debug('Background handler error: $e');
        }
      }

      if (needToLoadUrl) {
        if (_audioPlayer.processingState != ProcessingState.idle) {
          try {
            await _audioPlayer.stop();
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            Logger.debug('Error ensuring player is idle: $e');
          }
        }

        // Set audio source (handle file:// URLs for local files)
        String audioUrl = station.url;
        if (audioUrl.startsWith('file://')) {
          audioUrl = audioUrl.replaceFirst('file://', '');
        }

        await _audioPlayer.setUrl(
          audioUrl,
          preload: true,
        );
      }

      // Start playback through handler so Android starts foreground service and shows notification
      if (_audioHandler != null) {
        await (_audioHandler as BackgroundAudioHandler).play();
      } else {
        await _audioPlayer.play();
      }

      Logger.info('Playing station: ${station.name}');
      switch (action) {
        case PlayAnalyticsAction.play:
          AnalyticsService.logPlayStation(station, screenName: screenName);
        case PlayAnalyticsAction.next:
          AnalyticsService.logPlayerNext(station, screenName: screenName);
        case PlayAnalyticsAction.previous:
          AnalyticsService.logPlayerPrevious(station, screenName: screenName);
        case PlayAnalyticsAction.localMusic:
          AnalyticsService.logLocalMusicPlay(
            musicName: station.name,
            screenName: screenName,
          );
      }
    } catch (e) {
      // Provide user-friendly error messages
      String errorMsg = 'Failed to play station';
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('unknownhostexception') || 
          errorString.contains('unable to resolve host')) {
        errorMsg = 'Unable to connect to station. Please check your internet connection.';
      } else if (errorString.contains('timeout')) {
        errorMsg = 'Connection timeout. Please try again.';
      } else if (errorString.contains('404') || 
                 errorString.contains('not found') ||
                 errorString.contains('invalidresponsecode')) {
        errorMsg = 'Station not found. This stream may be unavailable.';
      } else if (errorString.contains('cleartext') || 
                 errorString.contains('http traffic not permitted')) {
        errorMsg = 'HTTP connection not allowed. Please use HTTPS streams.';
      } else if (errorString.contains('source error')) {
        errorMsg = 'Stream error. This station may be unavailable or the URL has changed.';
      } else if (errorString.contains('403') || errorString.contains('forbidden')) {
        errorMsg = 'Access denied. This station may require authentication.';
      } else if (errorString.contains('500') || errorString.contains('502') || 
                 errorString.contains('503')) {
        errorMsg = 'Server error. Please try again later.';
      }
      
      errorMessage.value = errorMsg;
      Logger.error('Failed to play station', 'AudioService', e);
      AnalyticsService.logPlaybackFailed(errorMsg);
      await CrashlyticsService.recordError(
        e,
        StackTrace.current,
        reason: 'play_station failed: $screenName',
        fatal: false,
      );
      isLoading.value = false;
      currentStation.value = null;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      Logger.debug('Playback paused');
    } catch (e) {
      Logger.error('Failed to pause', 'AudioService', e);
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      Logger.debug('Playback resumed');
    } catch (e) {
      Logger.error('Failed to resume', 'AudioService', e);
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      if (_audioPlayer.playing || currentStation.value != null) {
        await _audioPlayer.stop();
      }
      currentStation.value = null;
      errorMessage.value = '';
      isLoading.value = false;
      Logger.debug('Playback stopped');
    } catch (e) {
      Logger.error('Failed to stop', 'AudioService', e);
      currentStation.value = null;
      isLoading.value = false;
    }
  }

  /// Toggle play/pause (e.g. mini player).
  Future<void> togglePlayPause() async {
    if (playerState.playing) {
      AnalyticsService.logPausePlayback(screenName: AnalyticsScreens.miniPlayer);
      await pause();
    } else {
      AnalyticsService.logResumePlayback(screenName: AnalyticsScreens.miniPlayer);
      await resume();
    }
  }

  /// Next station (from notification/headset). Uses PlayerController if available.
  Future<void> playNext() async {
    try {
      if (Get.isRegistered<PlayerController>()) {
        await Get.find<PlayerController>().playNext();
      }
    } catch (e) {
      Logger.debug('playNext: $e');
    }
  }

  /// Previous station (from notification/headset). Uses PlayerController if available.
  Future<void> playPrevious() async {
    try {
      if (Get.isRegistered<PlayerController>()) {
        await Get.find<PlayerController>().playPrevious();
      }
    } catch (e) {
      Logger.debug('playPrevious: $e');
    }
  }

  /// Check if currently paused
  bool get isPaused => !isPlaying.value && currentStation.value != null;

  /// Check if stopped
  bool get isStopped => currentStation.value == null;

  /// Set playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (volume < 0 || volume > 1) return;
    try {
      await _audioPlayer.setVolume(volume);
      isMuted.value = volume == 0;
    } catch (e) {
      Logger.error('Failed to set volume', 'AudioService', e);
    }
  }

  /// Toggle mute: if muted, unmute and restore previous volume; otherwise mute.
  Future<void> toggleMute() async {
    try {
      if (isMuted.value) {
        await _audioPlayer.setVolume(_savedVolumeBeforeMute);
        isMuted.value = false;
      } else {
        _savedVolumeBeforeMute = _audioPlayer.volume;
        await _audioPlayer.setVolume(0);
        isMuted.value = true;
      }
    } catch (e) {
      Logger.error('Failed to toggle mute', 'AudioService', e);
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _audioHandler?.stop();
    super.onClose();
  }
}


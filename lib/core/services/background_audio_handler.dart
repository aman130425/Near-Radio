import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart';
import '../constants/app_constants.dart';
import 'audio_service.dart' as app_audio;

/// Background audio handler for audio_service.
/// Uses the same AudioPlayer as AudioService (single source of truth) and
/// delegates play/pause/stop to AudioService so only one player runs.
class BackgroundAudioHandler extends audio_service.BaseAudioHandler
    with audio_service.QueueHandler, audio_service.SeekHandler {
  final app_audio.AudioService _audioService;
  final AudioPlayer _player;

  BackgroundAudioHandler({
    required app_audio.AudioService audioService,
    required AudioPlayer player,
  })  : _audioService = audioService,
        _player = player {
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _player.playerStateStream.listen((_) => _updatePlaybackState());
    _player.positionStream.listen((_) => _updatePlaybackState());
    _player.durationStream.listen((_) => _updatePlaybackState());
  }

  static audio_service.AudioProcessingState _toAudioProcessingState(ProcessingState s) {
    switch (s) {
      case ProcessingState.idle:
        return audio_service.AudioProcessingState.idle;
      case ProcessingState.loading:
        return audio_service.AudioProcessingState.loading;
      case ProcessingState.buffering:
        return audio_service.AudioProcessingState.buffering;
      case ProcessingState.ready:
        return audio_service.AudioProcessingState.ready;
      case ProcessingState.completed:
        return audio_service.AudioProcessingState.completed;
    }
  }

  void _updatePlaybackState() {
    final state = _player.playerState;
    final currentState = playbackState.value;
    final processingState = _toAudioProcessingState(state.processingState);
    // Playing → show Pause button; Paused/Idle → show Play button
    final showPause = state.playing;
    playbackState.add(currentState.copyWith(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        if (showPause) audio_service.MediaControl.pause else audio_service.MediaControl.play,
        audio_service.MediaControl.skipToNext,
        audio_service.MediaControl.stop,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      playing: state.playing,
      processingState: processingState,
      updatePosition: _player.position,
      speed: _player.speed,
    ));
  }

  /// Update notification to match system media style: station name as title,
  /// "Category, Country" as subtitle (e.g. "News, Indian"), station logo as thumbnail,
  /// and Previous / Play-Pause / Next / Stop controls with progress.
  void setNotificationMediaFromStation(RadioStation station) {
    final parts = <String>[];
    if (station.category != null && station.category!.isNotEmpty) {
      parts.add(station.category!);
    }
    if (station.country != null && station.country!.isNotEmpty) {
      parts.add(station.country!);
    }
    final subtitle = parts.isNotEmpty ? parts.join(', ') : AppConstants.appName;

    mediaItem.add(audio_service.MediaItem(
      id: station.id,
      title: station.name,
      artist: subtitle,
      album: AppConstants.appName,
      artUri: station.logo != null && station.logo!.isNotEmpty
          ? Uri.parse(station.logo!)
          : null,
      duration: null,
      extras: {
        'url': station.url,
        'category': station.category ?? '',
        'country': station.country ?? '',
      },
    ));
    _updatePlaybackState();
  }

  @override
  Future<void> play() => _audioService.resume();

  @override
  Future<void> pause() => _audioService.pause();

  @override
  Future<void> stop() async {
    await _audioService.stop();
    // Push idle so Android removes/hides the notification (pause or app kill)
    playbackState.add(playbackState.value.copyWith(
      processingState: audio_service.AudioProcessingState.idle,
      playing: false,
    ));
    mediaItem.add(null);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async => _audioService.playNext();

  @override
  Future<void> skipToPrevious() async => _audioService.playPrevious();

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  Future<void> onStop() async {
    // Do not dispose _player - it is owned by AudioService
  }
}

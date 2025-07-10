import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  static AudioPlayer? _player;
  static String? _currentUrl;
  static bool _isPlaying = false;
  static Duration _currentPosition = Duration.zero;
  static Duration _totalDuration = Duration.zero;
  
  // Stream controllers for listening to player state
  static final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<Duration> positionNotifier = ValueNotifier<Duration>(Duration.zero);
  static final ValueNotifier<Duration> durationNotifier = ValueNotifier<Duration>(Duration.zero);
  static final ValueNotifier<String?> currentUrlNotifier = ValueNotifier<String?>(null);
  
  // Initialize player
  static Future<void> initialize() async {
    if (_player == null) {
      _player = AudioPlayer();
      
      // Listen to player state changes
      _player!.onPlayerStateChanged.listen((PlayerState state) {
        _isPlaying = state == PlayerState.playing;
        isPlayingNotifier.value = _isPlaying;
      });
      
      // Listen to position changes
      _player!.onPositionChanged.listen((Duration position) {
        _currentPosition = position;
        positionNotifier.value = position;
      });
      
      // Listen to duration changes
      _player!.onDurationChanged.listen((Duration duration) {
        _totalDuration = duration;
        durationNotifier.value = duration;
      });
      
      // Listen to completion
      _player!.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        isPlayingNotifier.value = false;
        positionNotifier.value = Duration.zero;
      });
    }
  }
  
  // Play audio from URL
  static Future<void> playFromUrl(String audioUrl) async {
    try {
      await initialize();
      debugPrint('AudioPlayerService: Attempting to play audio from $audioUrl');
      
      if (_currentUrl == audioUrl && _isPlaying) {
        // If same audio is playing, pause it
        await pause();
        return;
      }
      
      if (_currentUrl != audioUrl) {
        // Stop current audio if different URL
        await stop();
        _currentUrl = audioUrl;
        currentUrlNotifier.value = audioUrl;
      }
      
      // Play the audio
      await _player!.play(UrlSource(audioUrl));
      debugPrint('AudioPlayerService: Playing audio from $audioUrl');
    } catch (e) {
      debugPrint('AudioPlayerService: Error playing audio: $e');
      // Show error in UI
      debugPrint('AudioPlayerService: Make sure the audio URL is valid and accessible');
    }
  }
  
  // Pause audio
  static Future<void> pause() async {
    if (_player != null) {
      await _player!.pause();
      debugPrint('AudioPlayerService: Audio paused');
    }
  }
  
  // Resume audio
  static Future<void> resume() async {
    if (_player != null) {
      await _player!.resume();
      debugPrint('AudioPlayerService: Audio resumed');
    }
  }
  
  // Stop audio
  static Future<void> stop() async {
    if (_player != null) {
      await _player!.stop();
      _currentUrl = null;
      _currentPosition = Duration.zero;
      currentUrlNotifier.value = null;
      positionNotifier.value = Duration.zero;
      debugPrint('AudioPlayerService: Audio stopped');
    }
  }
  
  // Seek to position
  static Future<void> seek(Duration position) async {
    if (_player != null) {
      await _player!.seek(position);
    }
  }
  
  // Get current state
  static bool get isPlaying => _isPlaying;
  static String? get currentUrl => _currentUrl;
  static Duration get currentPosition => _currentPosition;
  static Duration get totalDuration => _totalDuration;
  
  // Check if specific URL is currently playing
  static bool isUrlPlaying(String url) {
    return _currentUrl == url && _isPlaying;
  }
  
  // Dispose player
  static Future<void> dispose() async {
    if (_player != null) {
      await _player!.dispose();
      _player = null;
      _currentUrl = null;
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      
      // Reset notifiers
      isPlayingNotifier.value = false;
      positionNotifier.value = Duration.zero;
      durationNotifier.value = Duration.zero;
      currentUrlNotifier.value = null;
    }
  }
}

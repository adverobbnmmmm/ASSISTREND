import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import '../models/upload_model.dart';

/// Service for recording audio on mobile devices
class AudioRecorderService {
  static final AudioRecorder _recorder = AudioRecorder();
  static bool _isRecording = false;
  static String? _currentRecordingPath;
  
  /// Check if currently recording
  static bool get isRecording => _isRecording;
  
  /// Get current recording path
  static String? get currentRecordingPath => _currentRecordingPath;
  
  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      // First check if the recorder has permission
      final hasPermission = await _recorder.hasPermission();
      if (hasPermission) {
        debugPrint('AudioRecorderService: Microphone permission already granted via recorder');
        return true;
      }
      
      // Check current status using permission_handler
      final status = await Permission.microphone.status;
      debugPrint('AudioRecorderService: Current permission status: $status');
      
      if (status.isGranted) {
        debugPrint('AudioRecorderService: Microphone permission already granted');
        return true;
      }
      
      if (status.isDenied) {
        debugPrint('AudioRecorderService: Requesting microphone permission');
        final newStatus = await Permission.microphone.request();
        debugPrint('AudioRecorderService: New permission status: $newStatus');
        if (newStatus.isGranted) {
          debugPrint('AudioRecorderService: Microphone permission granted');
          return true;
        } else {
          debugPrint('AudioRecorderService: Microphone permission denied after request');
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('AudioRecorderService: Microphone permission permanently denied');
        // You might want to show a dialog to open settings
        return false;
      }
      
      debugPrint('AudioRecorderService: Microphone permission status: $status');
      return false;
    } catch (e) {
      debugPrint('AudioRecorderService: Error requesting microphone permission: $e');
      // Try to use recorder's built-in permission as fallback
      try {
        final hasPermission = await _recorder.hasPermission();
        debugPrint('AudioRecorderService: Fallback permission check: $hasPermission');
        return hasPermission;
      } catch (fallbackError) {
        debugPrint('AudioRecorderService: Fallback permission check failed: $fallbackError');
        return false;
      }
    }
  }
  
  /// Start recording audio
  static Future<bool> startRecording() async {
    try {
      // Check permission
      if (!await requestMicrophonePermission()) {
        debugPrint('AudioRecorderService: Microphone permission denied');
        return false;
      }
      
      // Check if already recording
      if (_isRecording) {
        debugPrint('AudioRecorderService: Already recording');
        return false;
      }
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = path.join(tempDir.path, fileName);
      
      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      );
      
      // Start recording
      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      
      debugPrint('AudioRecorderService: Recording started at $_currentRecordingPath');
      return true;
    } catch (e) {
      debugPrint('AudioRecorderService: Error starting recording: $e');
      return false;
    }
  }
  
  /// Stop recording and return UploadMedia
  static Future<UploadMedia?> stopRecording() async {
    try {
      if (!_isRecording) {
        debugPrint('AudioRecorderService: Not currently recording');
        return null;
      }
      
      // Stop recording
      final recordedPath = await _recorder.stop();
      _isRecording = false;
      
      if (recordedPath == null) {
        debugPrint('AudioRecorderService: Recording path is null');
        return null;
      }
      
      final file = File(recordedPath);
      if (!file.existsSync()) {
        debugPrint('AudioRecorderService: Recorded file does not exist');
        return null;
      }
      
      // Get file size to estimate duration (rough estimate)
      final fileSize = await file.length();
      final estimatedDurationMs = (fileSize / 16000).round(); // Very rough estimate
      
      debugPrint('AudioRecorderService: Recording stopped successfully');
      debugPrint('AudioRecorderService: File size: $fileSize bytes');
      debugPrint('AudioRecorderService: Estimated duration: ${estimatedDurationMs}ms');
      
      return UploadMedia(
        file: file,
        path: recordedPath,
        type: MediaType.audio,
        durationMs: estimatedDurationMs,
      );
    } catch (e) {
      debugPrint('AudioRecorderService: Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }
  
  /// Cancel current recording
  static Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        
        // Delete the recorded file
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (file.existsSync()) {
            await file.delete();
          }
        }
        
        debugPrint('AudioRecorderService: Recording canceled');
      }
    } catch (e) {
      debugPrint('AudioRecorderService: Error canceling recording: $e');
    }
  }
  
  /// Get recording duration in milliseconds
  static Future<int?> getRecordingDuration() async {
    try {
      if (!_isRecording) return null;
      
      // This is a placeholder - you might want to implement actual duration tracking
      // For now, return null as duration will be calculated after recording stops
      return null;
    } catch (e) {
      debugPrint('AudioRecorderService: Error getting recording duration: $e');
      return null;
    }
  }
  
  /// Dispose resources
  static Future<void> dispose() async {
    try {
      if (_isRecording) {
        await cancelRecording();
      }
      await _recorder.dispose();
    } catch (e) {
      debugPrint('AudioRecorderService: Error disposing: $e');
    }
  }
}

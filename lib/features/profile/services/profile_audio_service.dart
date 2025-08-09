import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:cloudinary_public/cloudinary_public.dart';

/// Service for handling profile audio recording, uploading, and playback
class ProfileAudioService {
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
        debugPrint('ProfileAudioService: Microphone permission already granted via recorder');
        return true;
      }
      
      // Check current status using permission_handler
      final status = await Permission.microphone.status;
      debugPrint('ProfileAudioService: Current permission status: $status');
      
      if (status.isGranted) {
        debugPrint('ProfileAudioService: Microphone permission already granted');
        return true;
      }
      
      if (status.isDenied) {
        debugPrint('ProfileAudioService: Requesting microphone permission');
        final newStatus = await Permission.microphone.request();
        debugPrint('ProfileAudioService: New permission status: $newStatus');
        if (newStatus.isGranted) {
          debugPrint('ProfileAudioService: Microphone permission granted');
          return true;
        } else {
          debugPrint('ProfileAudioService: Microphone permission denied after request');
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('ProfileAudioService: Microphone permission permanently denied');
        return false;
      }
      
      debugPrint('ProfileAudioService: Microphone permission status: $status');
      return false;
    } catch (e) {
      debugPrint('ProfileAudioService: Error requesting microphone permission: $e');
      try {
        final hasPermission = await _recorder.hasPermission();
        debugPrint('ProfileAudioService: Fallback permission check: $hasPermission');
        return hasPermission;
      } catch (fallbackError) {
        debugPrint('ProfileAudioService: Fallback permission check failed: $fallbackError');
        return false;
      }
    }
  }
  
  /// Start recording audio
  static Future<bool> startRecording() async {
    try {
      // Check permission
      if (!await requestMicrophonePermission()) {
        debugPrint('ProfileAudioService: Microphone permission denied');
        return false;
      }
      
      // Check if already recording
      if (_isRecording) {
        debugPrint('ProfileAudioService: Already recording');
        return false;
      }
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'profile_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
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
      
      debugPrint('ProfileAudioService: Recording started at $_currentRecordingPath');
      return true;
    } catch (e) {
      debugPrint('ProfileAudioService: Error starting recording: $e');
      return false;
    }
  }
  
  /// Stop recording and return file path
  static Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        debugPrint('ProfileAudioService: Not currently recording');
        return null;
      }
      
      // Stop recording
      final recordedPath = await _recorder.stop();
      _isRecording = false;
      
      if (recordedPath == null) {
        debugPrint('ProfileAudioService: Recording path is null');
        return null;
      }
      
      final file = File(recordedPath);
      if (!file.existsSync()) {
        debugPrint('ProfileAudioService: Recorded file does not exist');
        return null;
      }
      
      debugPrint('ProfileAudioService: Recording stopped successfully');
      return recordedPath;
    } catch (e) {
      debugPrint('ProfileAudioService: Error stopping recording: $e');
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
        
        debugPrint('ProfileAudioService: Recording canceled');
      }
    } catch (e) {
      debugPrint('ProfileAudioService: Error canceling recording: $e');
    }
  }
  
  /// Pick audio file from device
  static Future<String?> pickAudioFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        // User canceled the picker
        return null;
      }
      
      final PlatformFile platformFile = result.files.first;
      
      // Handle null paths (which can happen on web)
      if (platformFile.path == null) {
        throw Exception('File path is null');
      }
      
      return platformFile.path!;
    } catch (e) {
      debugPrint('ProfileAudioService: Error picking audio: $e');
      throw Exception('Failed to pick audio: $e');
    }
  }
  
  /// Upload audio file to Cloudinary
  static Future<String?> uploadToCloudinary(String filePath) async {
    try {
      final cloudinary = CloudinaryPublic('dwnhpd6oe', 'unsigned_preset', cache: false);
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Video), // Audio as video
      );
      
      debugPrint('ProfileAudioService: Audio uploaded to Cloudinary: ${response.secureUrl}');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint('ProfileAudioService: Cloudinary Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('ProfileAudioService: Upload Error: $e');
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
      debugPrint('ProfileAudioService: Error disposing: $e');
    }
  }
}

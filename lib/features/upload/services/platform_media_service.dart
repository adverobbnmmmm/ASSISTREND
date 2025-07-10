import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_model.dart';

/// This service provides platform-specific implementations
/// for picking files and handling media uploads.
/// 
/// This is a platform-agnostic service that provides mock implementations
/// for Windows/desktop since some packages aren't fully supported there.
class PlatformMediaService {
  final bool isMobileOrWeb;
  
  PlatformMediaService() : isMobileOrWeb = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Pick an image from camera or gallery
  /// On Windows/desktop, this returns a mock implementation
  Future<UploadMedia?> pickImage(bool fromCamera) async {
    if (isMobileOrWeb) {
      debugPrint('Picking image on mobile platform');
      
      // On actual mobile devices, we should return null to let the app's
      // upload_provider.dart handle the actual image picking process
      // This allows the proper permission prompts and selection UI to appear
      return null;
    } else {
      // Windows/Desktop implementation - always return a mock
      debugPrint('Using mock image picker on ${Platform.operatingSystem}');
      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
      
      return UploadMedia(
        file: null, // No real file on desktop mock
        path: fromCamera ? 'mock_camera_image.jpg' : 'mock_gallery_image.jpg',
        type: MediaType.image,
      );
    }
  }
  
  /// Pick a video
  /// On Windows/desktop, this returns a mock implementation
  Future<UploadMedia?> pickVideo() async {
    if (isMobileOrWeb) {
      debugPrint('Picking video on mobile platform');
      
      // Return null on mobile to let the actual picker UI be shown
      // This will allow the upload provider to use the proper image_picker
      return null;
    } else {
      // Windows/Desktop implementation - always return a mock
      debugPrint('Using mock video picker on ${Platform.operatingSystem}');
      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
      
      return UploadMedia(
        file: null,
        path: 'mock_video_path.mp4',
        type: MediaType.video,
        thumbnail: 'mock_thumbnail.jpg',
        durationMs: 30000, // 30 seconds mock duration
      );
    }
  }
  
  /// Pick an audio file
  /// On Windows/desktop, this returns a mock implementation
  Future<UploadMedia?> pickAudio() async {
    if (isMobileOrWeb) {
      debugPrint('Picking audio on mobile platform');
      
      // Return null on mobile to let the actual picker UI be shown
      // This will allow the upload provider to use proper file_picker
      return null;
    } else {
      // Windows/Desktop implementation - always return a mock
      debugPrint('Using mock audio picker on ${Platform.operatingSystem}');
      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
      
      return UploadMedia(
        file: null,
        path: 'mock_audio_path.mp3',
        type: MediaType.audio,
      );
    }
  }

  /// Check for permissions
  /// On Windows/desktop, always returns true
  bool hasPermission(String permissionType) {
    if (isMobileOrWeb) {
      // Real permission checks would happen on mobile using permission_handler
      return true;
    } else {
      // On desktop, always return true since permissions are different
      debugPrint('Simulating permission $permissionType on desktop');
      return true;
    }
  }
}

/// Provider for the platform media service
final platformMediaServiceProvider = Provider<PlatformMediaService>((ref) {
  return PlatformMediaService();
});

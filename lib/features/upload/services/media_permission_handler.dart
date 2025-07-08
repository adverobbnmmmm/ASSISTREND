import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper for handling media permissions across different platforms and Android versions
class MediaPermissionHandler {
  /// Request all media-related permissions based on platform and OS version
  static Future<bool> requestMediaPermissions() async {
    if (kIsWeb) {
      return true; // Web doesn't need explicit permissions
    }
    
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true; // Desktop platforms don't need these permissions
    }
    
    try {
      if (Platform.isAndroid) {
        // Android 13+ (SDK 33+) uses more granular permissions
        if (await deviceSdkVersion() >= 33) {
          final photos = await Permission.photos.request();
          final videos = await Permission.videos.request();
          
          return photos.isGranted && videos.isGranted;
        } else {
          // Older Android versions use storage permission
          final storage = await Permission.storage.request();
          return storage.isGranted;
        }
      } else if (Platform.isIOS) {
        // iOS permissions
        final photos = await Permission.photos.request();
        return photos.isGranted;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting media permissions: $e');
      return false;
    }
  }
  
  /// Helper to get the Android SDK version
  static Future<int> deviceSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        return int.parse(Platform.operatingSystemVersion.split(' ').first);
      }
    } catch (e) {
      debugPrint('Error getting SDK version: $e');
    }
    return 0;
  }
}

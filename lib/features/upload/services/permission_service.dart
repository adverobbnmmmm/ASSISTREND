import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// This is a platform-agnostic permission service that works on both mobile and desktop
/// For mobile it would use permission_handler package
/// For desktop it mocks the permission behavior for testing UI and flow
class PermissionService {
  static bool get _isMobilePlatform => 
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Request camera permission, mocked on desktop
  static Future<bool> requestCameraPermission(BuildContext context) async {
    if (!_isMobilePlatform) {
      // On desktop platforms, show mock message and return true
      _showMockPermissionInfo(
        context: context,
        title: 'Camera Access',
        message: 'Camera access would be requested on a mobile device.',
      );
      return true;
    }
    
    // On mobile platform this would use the permission_handler package
    // For now, just return true to simulate granted permission
    debugPrint('PermissionService: Camera permission requested on mobile device');
    
    // In a real implementation, you would use permission_handler:
    // final status = await Permission.camera.request();
    // return status.isGranted;
    
    return true;
  }

  /// Request storage permission, mocked on desktop
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (!_isMobilePlatform) {
      _showMockPermissionInfo(
        context: context,
        title: 'Storage Access',
        message: 'Storage access would be requested on a mobile device.',
      );
      return true;
    }
    
    // On mobile platform this would use the permission_handler package
    return true;
  }

  /// Request video permission, mocked on desktop
  static Future<bool> requestVideoPermission(BuildContext context) async {
    if (!_isMobilePlatform) {
      _showMockPermissionInfo(
        context: context,
        title: 'Video Access',
        message: 'Video access would be requested on a mobile device.',
      );
      return true;
    }
    
    // On mobile platform this would use the permission_handler package
    return true;
  }

  /// Request audio permission, mocked on desktop
  static Future<bool> requestAudioPermission(BuildContext context) async {
    if (!_isMobilePlatform) {
      _showMockPermissionInfo(
        context: context,
        title: 'Audio Access',
        message: 'Audio access would be requested on a mobile device.',
      );
      return true;
    }
    
    // On mobile platform this would use the permission_handler package
    return true;
  }

  /// Show a mock permission information dialog
  static void _showMockPermissionInfo({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    // Show a non-blocking message at the bottom of the screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show a permission request dialog (for mobile)
  static void _showPermissionDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String permissionType,
    bool openSettings = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // On mobile, this would open app settings
              // openAppSettings(); // From permission_handler package
            },
            child: Text(openSettings ? 'Open Settings' : 'OK'),
          ),
        ],
      ),
    );
  }
}

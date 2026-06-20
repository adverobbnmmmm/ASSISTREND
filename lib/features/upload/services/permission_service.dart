import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Real permission service that uses permission_handler on all platforms.
class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Camera');
      return false;
    }

    final newStatus = await Permission.camera.request();
    if (newStatus.isGranted) return true;

    if (newStatus.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Camera');
    }
    return false;
  }

  /// Request storage / photos permission.
  /// On Android 13+ the granular media permissions (photos) replace
  /// the old storage permission.  We try the newer one first and fall
  /// back to the legacy one if it isn't available on this device.
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // Try granular Permission.photos first (Android 13+)
    var status = await Permission.photos.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Photos');
      return false;
    }

    if (status.isDenied) {
      final newStatus = await Permission.photos.request();
      if (newStatus.isGranted) return true;
      // If photos isn't a valid permission on this device (pre-Android 13),
      // permission_handler returns undetermined / limited — fall through.
    }

    // Fall back to legacy Permission.storage (Android 12 and below)
    status = await Permission.storage.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Storage');
      return false;
    }

    final newStatus = await Permission.storage.request();
    if (newStatus.isGranted) return true;

    if (newStatus.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Storage');
    }
    return false;
  }

  /// Request video permission (same approach — granular then fallback)
  static Future<bool> requestVideoPermission(BuildContext context) async {
    var status = await Permission.videos.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Videos');
      return false;
    }

    if (status.isDenied) {
      final newStatus = await Permission.videos.request();
      if (newStatus.isGranted) return true;
    }

    return requestStoragePermission(context);
  }

  /// Request audio / music files permission
  static Future<bool> requestAudioPermission(BuildContext context) async {
    var status = await Permission.audio.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Audio Files');
      return false;
    }

    if (status.isDenied) {
      final newStatus = await Permission.audio.request();
      if (newStatus.isGranted) return true;
    }

    return requestStoragePermission(context);
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Microphone');
      return false;
    }

    final newStatus = await Permission.microphone.request();
    if (newStatus.isGranted) return true;

    if (newStatus.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'Microphone');
    }
    return false;
  }

  /// Show dialog when a permission is permanently denied (user must go to settings).
  static void _showPermanentlyDeniedDialog(
    BuildContext context,
    String permissionName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          '$permissionName Permission Required',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Assistrend needs $permissionName access to continue. '
          'Please grant the permission in your device settings.',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

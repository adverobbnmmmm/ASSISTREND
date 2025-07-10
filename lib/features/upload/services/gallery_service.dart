import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/upload_model.dart';

/// A simplified gallery service for accessing device photos and videos
/// This implementation doesn't rely on photo_manager and uses image_picker instead
class GalleryService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Returns a list of recent media items 
  /// This implementation uses placeholders with actual working tap functionality
  static Future<List<RecentMedia>> getRecentMedia({int limit = 30}) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('GalleryService: Platform not supported for recent media');
      return _getMockRecentMedia(limit);
    }
    
    try {
      debugPrint('GalleryService: Setting up media placeholders');
      
      // Check permissions
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        final photosStatus = await Permission.photos.request();
        
        if (storageStatus.isDenied || photosStatus.isDenied) {
          debugPrint('GalleryService: Permission denied');
          return _getMockRecentMedia(limit);
        }
      } else if (Platform.isIOS) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied) {
          debugPrint('GalleryService: Permission denied');
          return _getMockRecentMedia(limit);
        }
      }
      
      // Generate functional media placeholders
      // In a real implementation, we would use a native plugin to get actual thumbnails
      // But for now, we'll create placeholders that work when tapped
      final List<RecentMedia> results = [];
      
      // Create a variety of mock items (some photo, some video)
      for (int i = 0; i < limit; i++) {
        results.add(
          RecentMedia(
            path: 'gallery_item_$i',
            type: i % 4 == 0 ? MediaType.video : MediaType.image,
            timestamp: DateTime.now().subtract(Duration(hours: i)),
            isMock: true, // These are mock but will open real pickers when tapped
          ),
        );
      }
      
      debugPrint('GalleryService: Generated ${results.length} functional placeholders');
      return results;
      
    } catch (e) {
      debugPrint('GalleryService: Error creating media placeholders: $e');
      return _getMockRecentMedia(limit);
    }
  }
  
  /// Pick an image when a thumbnail is tapped
  static Future<UploadMedia?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      final File file = File(pickedFile.path);
      
      return UploadMedia(
        file: file,
        path: pickedFile.path,
        type: MediaType.image,
      );
    } catch (e) {
      debugPrint('GalleryService: Error picking image: $e');
      return null;
    }
  }
  
  /// Pick a video when a thumbnail is tapped
  static Future<UploadMedia?> pickVideoFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      final File file = File(pickedFile.path);
      
      return UploadMedia(
        file: file,
        path: pickedFile.path,
        type: MediaType.video,
      );
    } catch (e) {
      debugPrint('GalleryService: Error picking video: $e');
      return null;
    }
  }
  
  /// Generates mock recent media that are just placeholders
  static List<RecentMedia> _getMockRecentMedia(int count) {
    debugPrint('GalleryService: Generating simple mock media placeholders');
    final List<RecentMedia> results = [];
    
    for (int i = 0; i < count; i++) {
      results.add(
        RecentMedia(
          path: 'mock_media_$i',
          type: i % 4 == 0 ? MediaType.video : MediaType.image,
          timestamp: DateTime.now().subtract(Duration(hours: i)),
          isMock: true,
        ),
      );
    }
    
    return results;
  }
}

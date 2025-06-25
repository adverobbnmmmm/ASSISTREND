import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/upload_model.dart';

/// This service provides the actual implementation of media picking
/// functionality for mobile platforms using image_picker and file_picker
class MobileMediaPicker {
  static final ImagePicker _imagePicker = ImagePicker();
  
  /// Pick image from camera or gallery
  static Future<UploadMedia?> pickImage(bool fromCamera) async {
    try {
      debugPrint('MobileMediaPicker: Opening ${fromCamera ? "camera" : "gallery"}');
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80, // Adjust quality as needed
      );
      
      if (pickedFile == null) {
        debugPrint('MobileMediaPicker: User canceled selection');
        // User canceled the picker
        return null;
      }
      
      debugPrint('MobileMediaPicker: Image picked at path: ${pickedFile.path}');
      final File file = File(pickedFile.path);
      debugPrint('MobileMediaPicker: File exists: ${file.existsSync()}');
      
      return UploadMedia(
        file: file,
        path: pickedFile.path,
        type: MediaType.image,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      throw Exception('Failed to pick image: $e');
    }
  }
  
  /// Pick video from camera or gallery
  static Future<UploadMedia?> pickVideo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (pickedFile == null) {
        // User canceled the picker
        return null;
      }
      
      final File file = File(pickedFile.path);
      
      // Generate video thumbnail
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: pickedFile.path,
        imageFormat: ImageFormat.JPEG,
        quality: 80,
      );
      
      return UploadMedia(
        file: file,
        path: pickedFile.path,
        type: MediaType.video,
        thumbnail: thumbnailPath,
      );
    } catch (e) {
      debugPrint('Error picking video: $e');
      throw Exception('Failed to pick video: $e');
    }
  }
  
  /// Pick audio file
  static Future<UploadMedia?> pickAudio() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
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
      
      final File file = File(platformFile.path!);
      
      return UploadMedia(
        file: file,
        path: platformFile.path!,
        type: MediaType.audio,
      );
    } catch (e) {
      debugPrint('Error picking audio: $e');
      throw Exception('Failed to pick audio: $e');
    }
  }
}

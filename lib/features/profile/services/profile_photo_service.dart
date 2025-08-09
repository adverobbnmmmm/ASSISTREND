import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Service for handling profile photo selection, uploading, and management
class ProfilePhotoService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      debugPrint('ProfilePhotoService: Current camera permission status: $status');
      
      if (status.isGranted) {
        debugPrint('ProfilePhotoService: Camera permission already granted');
        return true;
      }
      
      if (status.isDenied) {
        debugPrint('ProfilePhotoService: Requesting camera permission');
        final newStatus = await Permission.camera.request();
        debugPrint('ProfilePhotoService: New camera permission status: $newStatus');
        return newStatus.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('ProfilePhotoService: Camera permission permanently denied');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('ProfilePhotoService: Error requesting camera permission: $e');
      return false;
    }
  }
  
  /// Request photos permission
  static Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.status;
      debugPrint('ProfilePhotoService: Current photos permission status: $status');
      
      if (status.isGranted) {
        debugPrint('ProfilePhotoService: Photos permission already granted');
        return true;
      }
      
      if (status.isDenied) {
        debugPrint('ProfilePhotoService: Requesting photos permission');
        final newStatus = await Permission.photos.request();
        debugPrint('ProfilePhotoService: New photos permission status: $newStatus');
        return newStatus.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('ProfilePhotoService: Photos permission permanently denied');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('ProfilePhotoService: Error requesting photos permission: $e');
      return false;
    }
  }
  
  /// Take photo with camera
  static Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (photo == null) {
        debugPrint('ProfilePhotoService: User canceled camera');
        return null;
      }
      
      debugPrint('ProfilePhotoService: Photo taken: ${photo.path}');
      return photo.path;
    } catch (e) {
      debugPrint('ProfilePhotoService: Error taking photo: $e');
      throw Exception('Failed to take photo: $e');
    }
  }
  
  /// Pick photo from gallery
  static Future<String?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (photo == null) {
        debugPrint('ProfilePhotoService: User canceled gallery picker');
        return null;
      }
      
      debugPrint('ProfilePhotoService: Photo picked from gallery: ${photo.path}');
      return photo.path;
    } catch (e) {
      debugPrint('ProfilePhotoService: Error picking from gallery: $e');
      throw Exception('Failed to pick photo from gallery: $e');
    }
  }
  
  /// Pick image file using file picker (alternative method)
  static Future<String?> pickImageFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        debugPrint('ProfilePhotoService: User canceled file picker');
        return null;
      }
      
      final PlatformFile platformFile = result.files.first;
      
      if (platformFile.path == null) {
        throw Exception('File path is null');
      }
      
      debugPrint('ProfilePhotoService: Image file picked: ${platformFile.path}');
      return platformFile.path!;
    } catch (e) {
      debugPrint('ProfilePhotoService: Error picking image file: $e');
      throw Exception('Failed to pick image file: $e');
    }
  }
  
  /// Upload image file to Cloudinary
  static Future<String?> uploadToCloudinary(String filePath) async {
    try {
      final cloudinary = CloudinaryPublic('dwnhpd6oe', 'unsigned_preset', cache: false);
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Image),
      );
      
      debugPrint('ProfilePhotoService: Image uploaded to Cloudinary: ${response.secureUrl}');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint('ProfilePhotoService: Cloudinary Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('ProfilePhotoService: Upload Error: $e');
      return null;
    }
  }
  
  /// Show photo source selection dialog
  static Future<String?> showPhotoSourceDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Select Photo Source',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blueAccent),
                title: Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop('camera');
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop('gallery');
                },
              ),
              ListTile(
                leading: Icon(Icons.folder, color: Colors.orange),
                title: Text('File Manager', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop('file');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
  
  /// Complete photo selection workflow with source dialog
  static Future<String?> selectPhoto(BuildContext context) async {
    final source = await showPhotoSourceDialog(context);
    if (source == null) return null;
    
    try {
      switch (source) {
        case 'camera':
          final hasPermission = await requestCameraPermission();
          if (!hasPermission) {
            throw Exception('Camera permission is required');
          }
          return await takePhoto();
          
        case 'gallery':
          final hasPermission = await requestPhotosPermission();
          if (!hasPermission) {
            throw Exception('Photos permission is required');
          }
          return await pickFromGallery();
          
        case 'file':
          final hasPermission = await requestPhotosPermission();
          if (!hasPermission) {
            throw Exception('Storage permission is required');
          }
          return await pickImageFile();
          
        default:
          return null;
      }
    } catch (e) {
      debugPrint('ProfilePhotoService: Error in photo selection: $e');
      rethrow;
    }
  }
}

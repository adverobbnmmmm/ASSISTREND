import 'package:flutter/material.dart';
import '../services/profile_photo_service.dart';

/// Widget for managing profile photo upload and display
class ProfilePhotoWidget extends StatefulWidget {
  final String? currentProfileImageUrl;
  final Function(String?) onPhotoUploaded;
  final bool enabled;

  const ProfilePhotoWidget({
    Key? key,
    this.currentProfileImageUrl,
    required this.onPhotoUploaded,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  bool _isUploading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  /// Handle photo selection and upload
  Future<void> _selectAndUploadPhoto() async {
    if (!widget.enabled) return;

    try {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
        _uploadProgress = 0.0;
      });

      // Show progress for selection
      setState(() {
        _uploadProgress = 0.2;
      });

      // Select photo
      final photoPath = await ProfilePhotoService.selectPhoto(context);
      if (photoPath == null) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        return;
      }

      // Show progress for upload
      setState(() {
        _uploadProgress = 0.5;
      });

      // Upload to Cloudinary
      final photoUrl = await ProfilePhotoService.uploadToCloudinary(photoPath);
      
      setState(() {
        _uploadProgress = 0.9;
      });

      if (photoUrl != null) {
        // Notify parent widget
        widget.onPhotoUploaded(photoUrl);
        
        setState(() {
          _uploadProgress = 1.0;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile photo uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to upload photo to cloud storage');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  /// Remove current profile photo
  void _removePhoto() {
    if (!widget.enabled) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Remove Profile Photo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove your profile photo?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPhotoUploaded(null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile photo removed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.photo_camera,
                color: Colors.blue,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Profile Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Photo preview section
          if (widget.currentProfileImageUrl != null) ...[
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(58),
                  child: Image.network(
                    widget.currentProfileImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[800],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 30),
                            SizedBox(height: 4),
                            Text(
                              'Failed to load',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ] else ...[
            // Placeholder when no photo
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.grey[600]!, width: 2),
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Upload progress
          if (_isUploading) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Uploading photo...',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.enabled && !_isUploading ? _selectAndUploadPhoto : null,
                  icon: Icon(
                    widget.currentProfileImageUrl != null ? Icons.edit : Icons.add_a_photo,
                    size: 18,
                  ),
                  label: Text(
                    widget.currentProfileImageUrl != null ? 'Change Photo' : 'Add Photo',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (widget.currentProfileImageUrl != null) ...[
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: widget.enabled && !_isUploading ? _removePhoto : null,
                  icon: Icon(Icons.delete, size: 18),
                  label: Text('Remove', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Help text
          SizedBox(height: 12),
          Text(
            'Upload a profile photo from your camera, gallery, or files. Recommended size: 1024x1024 pixels.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

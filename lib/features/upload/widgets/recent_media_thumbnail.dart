import 'dart:io';
import 'package:flutter/material.dart';
import '../models/upload_model.dart';

/// Widget to display a recent media thumbnail from gallery
class RecentMediaThumbnail extends StatelessWidget {
  final RecentMedia media;
  final VoidCallback onTap;
  
  const RecentMediaThumbnail({
    Key? key,
    required this.media,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          _buildThumbnail(),
          
          // Video indicator if applicable
          if (media.isVideo)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          
          // Selection indicator overlay
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildThumbnail() {
    // If we have thumbnail data from photo_manager
    if (media.thumbnailData != null) {
      try {
        return Image.memory(
          media.thumbnailData!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading thumbnail data: $error');
            return _tryLoadFile();
          },
        );
      } catch (e) {
        debugPrint('Error displaying thumbnail data: $e');
        return _tryLoadFile();
      }
    } else {
      return _tryLoadFile();
    }
  }
  
  Widget _tryLoadFile() {
    // If thumbnailData is not available, try using the file
    if (media.hasFile) {
      try {
        return Image.file(
          media.file!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading thumbnail file: $error');
            return _buildPlaceholder();
          },
        );
      } catch (e) {
        debugPrint('Error displaying thumbnail file: $e');
        return _buildPlaceholder();
      }
    } else {
      return _buildPlaceholder();
    }
  }
  
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: media.isVideo 
              ? [Colors.purple.shade900, Colors.blue.shade900]
              : [Colors.blue.shade900, Colors.teal.shade900],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              media.isVideo ? Icons.video_collection_rounded : Icons.photo_library_rounded,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              media.isVideo ? 'Tap to select video' : 'Tap to select photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

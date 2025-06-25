import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/upload_model.dart';
import './video_preview_player.dart';

/// A widget that previews media (images, videos, audio) on both mobile and desktop
class MediaPreviewCard extends StatelessWidget {
  final UploadMedia media;
  final VoidCallback onDelete;
  
  const MediaPreviewCard({
    Key? key,
    required this.media,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Media preview - will show actual image/video on mobile if available
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMediaPreview(),
          ),
          
          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: onDelete,
            ),
          ),
          
          // Media type label
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getMediaTypeLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    // Try to show real file on mobile platforms
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS) && media.file != null) {
      try {
        switch (media.type) {
          case MediaType.image:
            return Image.file(
              media.file!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return _buildMockPreview(); // Fallback to mock preview
              },
            );
          case MediaType.video:
            debugPrint('MediaPreviewCard: Attempting to show video: ${media.path}');
            // First check if we have a valid file
            if (media.file != null) {
              try {
                if (media.file!.existsSync()) {
                  debugPrint('MediaPreviewCard: Video file exists, using VideoPreviewPlayer');
                  // Use thumbnail initially with play button for better UX
                  if (media.thumbnail != null && File(media.thumbnail!).existsSync()) {
                    return _buildVideoWithThumbnailPreview();
                  } else {
                    // No thumbnail available, try direct video player
                    return VideoPreviewPlayer(
                      videoFile: media.file!,
                    );
                  }
                } else {
                  debugPrint('MediaPreviewCard: Video file does not exist: ${media.file!.path}');
                }
              } catch (e) {
                debugPrint('MediaPreviewCard: Error initializing video player: $e');
              }
            }
            
            // Fallback to thumbnail if available
            if (media.thumbnail != null) {
              try {
                final thumbnailFile = File(media.thumbnail!);
                if (thumbnailFile.existsSync()) {
                  debugPrint('MediaPreviewCard: Using thumbnail fallback');
                  return _buildVideoWithThumbnailPreview();
                }
              } catch (thumbError) {
                debugPrint('MediaPreviewCard: Error showing thumbnail: $thumbError');
              }
            }
            
            debugPrint('MediaPreviewCard: Falling back to mock video preview');
            return _buildMockPreview();
          case MediaType.audio:
            return _buildMockPreview(); // Always show icon for audio
        }
      } catch (e) {
        debugPrint('Error in media preview: $e');
      }
    }
    
    // Fall back to mock preview for desktop or error cases
    return _buildMockPreview();
  }

  // The original mock preview with icons
  Widget _buildMockPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForMediaType(),
            size: 48,
            color: Colors.white70,
          ),
          const SizedBox(height: 8),
          Text(
            media.path != null 
                ? media.path!.split('/').last // Show just the filename
                : _getMediaTypeLabel(),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Build a video preview with thumbnail and play button
  Widget _buildVideoWithThumbnailPreview() {
    return GestureDetector(
      onTap: () {
        // In a more complete implementation, this would show a full video player
        debugPrint('Video thumbnail tapped');
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail as background
          Image.file(
            File(media.thumbnail!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildMockPreview(),
          ),
          // Play button overlay
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          // Duration indicator if available
          if (media.durationMs != null)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(media.durationMs!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Format milliseconds into a time string
  String _formatDuration(int milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds);
    final int minutes = duration.inMinutes;
    final int seconds = (duration.inSeconds) % 60;
    
    final String minutesString = '$minutes';
    final String secondsString = seconds < 10 ? '0$seconds' : '$seconds';
    
    return '$minutesString:$secondsString';
  }

  IconData _getIconForMediaType() {
    switch (media.type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.audio:
        return Icons.audiotrack;
    }
  }
  
  String _getMediaTypeLabel() {
    switch (media.type) {
      case MediaType.image:
        return 'IMAGE';
      case MediaType.video:
        return 'VIDEO';
      case MediaType.audio:
        return 'AUDIO';
    }
  }
}

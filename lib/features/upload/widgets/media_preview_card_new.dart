import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/upload_model.dart';
import 'video_preview_player.dart';

/// A widget that previews media (images, videos, audio) on both mobile and desktop
/// Designed to match Instagram's media preview experience
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // Media preview - will show actual image/video on mobile if available
        ClipRRect(
          borderRadius: BorderRadius.circular(0), // Instagram doesn't use rounded corners
          child: _buildMediaPreview(),
        ),
        
        // Controls overlay
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              // Media type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForMediaType(),
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getMediaTypeLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Delete button
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ),
      ],
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
                      autoPlay: true, // Auto-play for Instagram-like experience
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
            return _buildAudioPreview(); // Styled audio preview
        }
      } catch (e) {
        debugPrint('Error in media preview: $e');
      }
    }
    
    // Fallback to mock previews for desktop platforms
    return _buildMockPreview();
  }

  // Build audio preview with waveform-like visualization
  Widget _buildAudioPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple.shade800,
            Colors.deepPurple.shade600,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Audio icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.audiotrack,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Audio file name
          Text(
            media.path?.split('/').last ?? 'Audio Recording',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Duration if available
          if (media.durationMs != null)
            Text(
              _formatDuration(media.durationMs!),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Waveform visualization (mock)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              20,
              (index) => Container(
                width: 4,
                height: 20 + (index % 3) * 15,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mock preview for desktop and fallback situations
  Widget _buildMockPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade200,
            Colors.purple.shade200,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForMediaType(),
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Preview Available\nOn Mobile',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getMediaTypeLabel(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (media.path != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                media.path!.split('/').last,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // Video preview with thumbnail overlay
  Widget _buildVideoWithThumbnailPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail background
        if (media.thumbnail != null)
          Image.file(
            File(media.thumbnail!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading thumbnail: $error');
              return _buildMockPreview();
            },
          ),
        
        // Play button overlay
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        
        // Duration overlay (bottom right)
        if (media.durationMs != null)
          Positioned(
            bottom: 8,
            right: 12,
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
    );
  }

  // Format milliseconds into a time string - Instagram format
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
        return 'Photo';
      case MediaType.video:
        return 'Video';
      case MediaType.audio:
        return 'Audio';
    }
  }
}

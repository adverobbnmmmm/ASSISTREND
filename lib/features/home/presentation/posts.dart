import 'package:flutter/material.dart';

import 'postbottombar.dart';
import 'postheadbar.dart';
import '../models/post_model.dart';
import '../widgets/network_video_player.dart';
import '../widgets/instagram_audio_player.dart';

class AppPosts extends StatelessWidget {
  const AppPosts({super.key, this.img, this.post});
  final String? img;
  final Post? post;
  
  // Helper method to determine if URL is a video
  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'];
    final lowerUrl = url.toLowerCase();
    
    // Check for file extensions
    if (videoExtensions.any((ext) => lowerUrl.contains(ext))) {
      return true;
    }
    
    // Check for cloudinary video transformations
    if (lowerUrl.contains('cloudinary') && (
        lowerUrl.contains('/video/') || 
        lowerUrl.contains('f_auto,q_auto') ||
        lowerUrl.contains('resource_type/video')
    )) {
      return true;
    }
    
    // Check for video in URL path or query parameters
    if (lowerUrl.contains('video') || lowerUrl.contains('v_')) {
      return true;
    }
    
    return false;
  }
  
  // Helper method to get category name from category ID
  String? _getCategoryName(int? categoryId) {
    if (categoryId == null) return null;
    
    // Map category IDs to names - this should match your backend categories
    switch (categoryId) {
      case 1:
        return 'Opinion';
      case 2:
        return 'Experience';
      case 3:
        return 'Adventure';
      default:
        return 'General';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Use post data if available, otherwise fallback to img parameter
    final mediaUrl = post?.imageUrl ?? img ?? "";
    final caption = post?.caption ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
    final isVideo = _isVideoUrl(mediaUrl);
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.blueGrey[700] ?? Colors.blueGrey),
            bottom: BorderSide(color: Colors.blueGrey[700] ?? Colors.blueGrey),
            left: BorderSide.none,
            right: BorderSide.none),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          PostHeadBar(
            username: post?.username ?? 'Anonymous',
            category: _getCategoryName(post?.category),
            createdAt: post?.createdAt,
          ),
          if (mediaUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: isVideo 
                  ? _buildVideoPlayer(mediaUrl)
                  : _buildImageDisplay(mediaUrl),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              caption,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          // Show audio player if audio URL is available
          if (post?.audioUrl != null && post!.audioUrl!.isNotEmpty) ...[
            // Debug information
            Builder(
              builder: (context) {
                debugPrint('AppPosts: Audio URL detected: ${post!.audioUrl}');
                return InstagramAudioPlayer(
                  audioUrl: post!.audioUrl!,
                );
              },
            ),
          ] else if (post?.audioUrl != null) ...[
            // Debug: Show when audio URL is empty
            Builder(
              builder: (context) {
                debugPrint('AppPosts: Audio URL is empty or null');
                return const SizedBox.shrink();
              },
            ),
          ],
          PostBottomBar(post: post),
        ],
      ),
    );
  }
  
  Widget _buildImageDisplay(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[800],
          child: const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 50,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildVideoPlayer(String videoUrl) {
    return SizedBox(
      height: 300,
      child: NetworkVideoPlayer(videoUrl: videoUrl),
    );
  }
}

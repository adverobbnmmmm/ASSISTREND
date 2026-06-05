import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';
import '../models/profile_model.dart';
import '../../home/models/post_model.dart' as HomePost;
import '../../home/presentation/postheadbar.dart';
import '../../home/presentation/postbottombar.dart';
import '../../home/widgets/network_video_player.dart';

class SeeMorePostsPage extends ConsumerStatefulWidget {
  const SeeMorePostsPage({super.key});

  @override
  _SeeMorePostsPageState createState() => _SeeMorePostsPageState();
}

class _SeeMorePostsPageState extends ConsumerState<SeeMorePostsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    final List<String> tabs = ["Posts", "Liked", "Tagged"];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("See More Posts"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                tabs.length,
                (index) => GestureDetector(
                  onTap: () {
                    ref.read(selectedTabIndexProvider.notifier).state = index;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: selectedTabIndex == index
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      color: selectedTabIndex == index
                          ? Colors.grey[850]
                          : Colors.transparent,
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selectedTabIndex == index
                            ? Colors.white
                            : Colors.grey,
                        fontWeight: selectedTabIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          if (profileState.status == ProfileStatus.loading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else if (profileState.status == ProfileStatus.error)
            Expanded(
              child: Center(
                child: Text('Error: ${profileState.errorMessage}',
                    style: TextStyle(color: Colors.red)),
              ),
            )
          else
            Expanded(
              child: _buildSelectedTabContent(profileState.profile,
                  selectedTabIndex),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(ProfileModel profile, int selectedTabIndex) {
    switch (selectedTabIndex) {
      case 0:
        return _buildPostContent(profile);
      case 1:
        return _buildLikedContent(profile);
      case 2:
        return _buildTaggedContent(profile);
      default:
        return _buildPostContent(profile);
    }
  }

  Widget _buildPostContent(ProfileModel profile) {
    if (profile.posts.isEmpty) {
      return Center(
          child: Text('No posts available',
              style: TextStyle(color: Colors.white)));
    }

    // Sort posts by creation date (latest first)
    final sortedPosts = List<Post>.from(profile.posts);
    sortedPosts.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    return ListView.builder(
      itemCount: sortedPosts.length,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (context, index) {
        final post = sortedPosts[index];
        return _buildHomeStylePost(post, profile);
      },
    );
  }

  // Convert profile post to home post model for consistent UI
  HomePost.Post _convertToHomePost(Post profilePost, ProfileModel profile) {
    return HomePost.Post(
      id: profilePost.id,
      user: '', // Will be filled with actual user ID (UUID) if available
      username: profile.username,
      caption: profilePost.caption,
      imageUrl: profilePost.imageUrl,
      audioUrl: null, // Profile posts don't have audio in current model
      category: profilePost.category,
      createdAt: DateTime.parse(profilePost.createdAt),
      likesCount: profilePost.likesCount, // Real count from backend
      isLiked: false,
      commentsCount: profilePost.commentsCount, // Real count from backend
    );
  }

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

  Widget _buildHomeStylePost(Post profilePost, ProfileModel profile) {
    final homePost = _convertToHomePost(profilePost, profile);
    final mediaUrl = homePost.imageUrl;
    final caption = homePost.caption;
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
            username: homePost.username ?? 'Anonymous',
            category: _getCategoryName(homePost.category),
            createdAt: homePost.createdAt,
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
          // Show user interests
          // if (profile.interests.isNotEmpty) ...[
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          //     child: Align(
          //       alignment: Alignment.centerLeft,
          //       child: Wrap(
          //         spacing: 6,
          //         runSpacing: 6,
          //         children: profile.interests.map((interest) => 
          //           Container(
          //             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //             decoration: BoxDecoration(
          //               color: Colors.blue.withOpacity(0.2),
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //             child: Text(interest, 
          //               style: TextStyle(color: Colors.blue[300], fontSize: 12),
          //             ),
          //           )
          //         ).toList(),
          //       ),
          //     ),
          //   ),
          // ],
          PostBottomBar(post: homePost),
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

  // Helper method to create a placeholder post from post ID
  Post _createPlaceholderPost(int postId, String type) {
    return Post(
      id: postId,
      caption: 'This is a $type post #$postId. Full post data would be loaded from the backend.',
      imageUrl: '', // Empty for now - would be fetched from backend
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  Widget _buildLikedContent(ProfileModel profile) {
    if (profile.likedPosts.isEmpty) {
      return Center(
          child: Text('No liked posts',
              style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: profile.likedPosts.length,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (context, index) {
        final postId = profile.likedPosts[index];
        final placeholderPost = _createPlaceholderPost(postId, 'liked');
        return _buildHomeStylePost(placeholderPost, profile);
      },
    );
  }

  Widget _buildTaggedContent(ProfileModel profile) {
    if (profile.taggedPosts.isEmpty) {
      return Center(
          child: Text('No tagged posts',
              style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: profile.taggedPosts.length,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (context, index) {
        final postId = profile.taggedPosts[index];
        final placeholderPost = _createPlaceholderPost(postId, 'tagged');
        return _buildHomeStylePost(placeholderPost, profile);
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';
import '../models/profile_model.dart';

class SeeMorePostsPage extends ConsumerStatefulWidget {
  const SeeMorePostsPage({super.key});

  @override
  _SeeMorePostsPageState createState() => _SeeMorePostsPageState();
}

class _SeeMorePostsPageState extends ConsumerState<SeeMorePostsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<Color?> _likeColorAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeColorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.blue,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    final List<String> tabs = ["Posts", "Stories", "Liked", "Tagged"];

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
        return _buildStoriesContent(profile);
      case 2:
        return _buildLikedContent(profile);
      case 3:
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

    return ListView.builder(
      itemCount: profile.posts.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final post = profile.posts[index];
        return Column(
          children: [
            _buildSinglePost(post),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSinglePost(Post post) {
    bool _isLiked = false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/profile_pic.jpg"),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption.split(' ').take(2).join(' '), // First two words as title
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _getTimeAgo(DateTime.parse(post.createdAt)),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),

          // Post Content
          Text(
            post.caption,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Post Image
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[800],
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),

          // Post Actions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                  if (_isLiked) {
                    _likeAnimationController.forward();
                  } else {
                    _likeAnimationController.reverse();
                  }
                },
                child: AnimatedBuilder(
                  animation: _likeColorAnimation,
                  builder: (context, child) {
                    return Icon(
                      Icons.thumb_up_alt_outlined,
                      color: _isLiked ? Colors.blue : Colors.grey[400],
                      size: 28,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text("0", style: TextStyle(color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.comment_outlined, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesContent(ProfileModel profile) {
    if (profile.stories.isEmpty) {
      return Center(
          child: Text('No stories available',
              style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: profile.stories.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final story = profile.stories[index];
        return Card(
          color: Colors.grey[900],
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      child: Icon(Icons.auto_stories, color: Colors.blue),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Story ${story.id}",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getTimeAgo(DateTime.parse(story.createdAt)),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  story.content,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final postId = profile.likedPosts[index];
        return ListTile(
          title: Text('Liked Post #$postId',
              style: TextStyle(color: Colors.white)),
          leading: Icon(Icons.thumb_up, color: Colors.blue),
        );
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
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final postId = profile.taggedPosts[index];
        return ListTile(
          title: Text('Tagged in Post #$postId',
              style: TextStyle(color: Colors.white)),
          leading: Icon(Icons.tag, color: Colors.orange),
        );
      },
    );
  }
}
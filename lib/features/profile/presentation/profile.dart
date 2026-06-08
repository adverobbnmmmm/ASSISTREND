import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/profile/presentation/more_post.dart';
import 'package:assistrend/features/profile/presentation/edit_profile.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_providers.dart';
import '../models/profile_model.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/models/post_model.dart' as HomePost;
import '../../home/presentation/postbottombar.dart';
import '../../home/services/audio_player_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  /// null => the logged-in user's own profile (editable).
  /// otherwise => view that user's profile read-only.
  final String? userId;
  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final List<String> tabs = ["Posts", "Liked", "Tagged"];
  bool _isMenuOpen = false;

  bool get _isOwnProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    // Initialize audio player service
    AudioPlayerService.initialize();
    // Only the own profile uses the shared profileProvider; other users are
    // loaded read-only through otherUserProfileProvider in build().
    if (_isOwnProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserProfile();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);

    // Viewing another user's profile (read-only).
    if (!_isOwnProfile) {
      final async = ref.watch(otherUserProfileProvider(widget.userId!));
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: async.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.purple)),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load profile: $e',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),
          ),
          data: (profile) =>
              _buildProfileContent(profile, selectedTabIndex, isOwnProfile: false),
        ),
        floatingActionButton: _buildSpeedDial(),
      );
    }

    // Own profile.
    final profileState = ref.watch(profileProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _buildBody(profileState, selectedTabIndex),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  void _loadUserProfile() async {
    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId != null) {
        await ref.read(profileProvider.notifier).fetchProfile(userId);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not authenticated'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBody(ProfileState profileState, int selectedTabIndex) {
    switch (profileState.status) {
      case ProfileStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        );
      case ProfileStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${profileState.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadUserProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return _buildProfileContent(profileState.profile, selectedTabIndex,
            isOwnProfile: true);
    }
  }

  Widget _buildProfileContent(ProfileModel profile, int selectedTabIndex,
      {bool isOwnProfile = true}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _buildProfileHeader(profile, isOwnProfile),
          const SizedBox(height: 24),
          _buildAboutSection(profile, isOwnProfile),
          const SizedBox(height: 24),
          _buildInterestsSection(profile),
          const SizedBox(height: 24),
          _buildHighlightsSection(profile),
          const SizedBox(height: 24),
          _buildTabBar(selectedTabIndex),
          const SizedBox(height: 20),
          _buildSelectedTabContent(profile, selectedTabIndex),
          const SizedBox(height: 24),
          _buildSocialLinks(profile),
          const SizedBox(height: 32), // Add bottom padding for scrolling
        ],
      ),
    );
  }
  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'logout') _handleLogout();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) context.go('/');
    }
  }

  Widget _buildProfileHeader(ProfileModel profile, bool isOwnProfile) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                      ? NetworkImage(profile.profileImageUrl!)
                      : NetworkImage(
                          "https://ui-avatars.com/api/?name=${profile.name}&background=random"
                        ),
                  child: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                      ? null
                      : Text(
                          profile.emoji.isNotEmpty ? profile.emoji : profile.name.isNotEmpty 
                              ? profile.name[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                ),
              ),  
              if (isOwnProfile)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.blue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Icon(Icons.rocket_launch, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "@${profile.username}",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          if (isOwnProfile) _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProfileModel profile, bool isOwnProfile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "About",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  if (isOwnProfile) ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.pushNamed('editProfile', extra: profile);
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: profile.audioUrl != null 
                          ? Colors.blueAccent.withOpacity(0.5)
                          : Colors.grey.shade800.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: AudioPlayerService.isPlayingNotifier,
                      builder: (context, isPlaying, child) {
                        final isCurrentlyPlaying = profile.audioUrl != null && 
                            AudioPlayerService.isUrlPlaying(profile.audioUrl!);
                        
                        return IconButton(
                          onPressed: profile.audioUrl != null ? () async {
                            if (isCurrentlyPlaying) {
                              await AudioPlayerService.pause();
                            } else {
                              await AudioPlayerService.playFromUrl(profile.audioUrl!);
                            }
                          } : null,
                          icon: Icon(
                            isCurrentlyPlaying ? Icons.pause : Icons.play_arrow, 
                            color: profile.audioUrl != null ? Colors.white : Colors.grey
                          ),
                          iconSize: 16,
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            profile.about.isNotEmpty
                ? profile.about
                : "No bio yet. Tap edit to tell people about yourself.",
            style: TextStyle(
              color: profile.about.isNotEmpty
                  ? Colors.grey.shade300
                  : Colors.grey.shade600,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(ProfileModel profile) {
    final interests = profile.interests;

    return Container(
      margin: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interests",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          if (interests.isEmpty)
            Text(
              "No interests added yet.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: interests.map((interest) => _buildInterestChip(interest)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Text(
        interest,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHighlightsSection(ProfileModel profile) {
    if (profile.highlightQuestion == null || profile.highlightQuestion!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Highlight Question",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Ask me anything",
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile.highlightQuestion!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTabBar(int selectedTabIndex) {
    return Container(
      height: 45, // Increased height to accommodate text and indicator
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Changed to spaceAround for better spacing
              children: List.generate(
                tabs.length,
                (index) => GestureDetector( // Removed Expanded to prevent overflow
                  onTap: () {
                    ref.read(selectedTabIndexProvider.notifier).state = index;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          color: selectedTabIndex == index
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: selectedTabIndex == index
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14, // Slightly reduced font size
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Blue underline indicator for selected tab
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                          color: selectedTabIndex == index
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.grey.shade900,
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
      // Real counts from the backend
      likesCount: profilePost.likesCount,
      isLiked: false,
      commentsCount: profilePost.commentsCount,
    );
  }

  Widget _buildPostContent(ProfileModel profile) {
    if (profile.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.post_add, color: Colors.grey.shade600, size: 48),
              SizedBox(height: 16),
              Text(
                "No posts yet",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Sort posts by creation date (latest first) and get the latest one
    final sortedPosts = List<Post>.from(profile.posts);
    sortedPosts.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
    final latestPost = sortedPosts.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildSinglePost(latestPost, profile),
          if (profile.posts.length > 1) ...[
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeMorePostsPage(),
                    ),
                  );
                },
                child: const Text(
                  "See more posts",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildSinglePost(Post post, ProfileModel profile) {
    // Convert to home post for consistent UI with likes/comments
    final homePost = _convertToHomePost(post, profile);
    
    DateTime postDate = DateTime.parse(post.createdAt);
    String timeAgo = _getTimeAgo(postDate);
    String username = profile.name;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                    ? NetworkImage(profile.profileImageUrl!)
                    : NetworkImage(
                        "https://ui-avatars.com/api/?name=${profile.name}&background=random"
                      ),
                child: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                    ? null
                    : Text(
                        profile.emoji.isNotEmpty ? profile.emoji : profile.name.isNotEmpty 
                            ? profile.name[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$timeAgo ago",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 18,
              ),
            ],
          ),
          
          // Post content
          const SizedBox(height: 12),
          Text(
            post.caption,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          
          // Post image if available
          if (post.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
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
                        color: Colors.grey.shade800,
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade600, size: 40),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.indigo,
                          Colors.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(2), // Border thickness
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A), // Dark background
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "Experience",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Post actions using home page style
          const SizedBox(height: 12),
          // Debug: Show the actual counts being passed
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   margin: EdgeInsets.only(bottom: 8),
          //   decoration: BoxDecoration(
          //     color: Colors.blue.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Text(
          //     'Likes: ${homePost.likesCount} | Comments: ${homePost.commentsCount} | Liked: ${homePost.isLiked}',
          //     style: TextStyle(
          //       color: Colors.blue,
          //       fontSize: 10,
          //     ),
          //   ),
          // ),
          PostBottomBar(post: homePost),
        ],
      ),
    );
  }
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Widget _buildLikedContent(ProfileModel profile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.favorite_border, color: Colors.grey.shade600, size: 48),
            SizedBox(height: 16),
            Text(
              profile.likedPosts.isEmpty 
                  ? "No liked posts"
                  : "Liked ${profile.likedPosts.length} posts",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaggedContent(ProfileModel profile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.tag, color: Colors.grey.shade600, size: 48),
            SizedBox(height: 16),
            Text(
              profile.taggedPosts.isEmpty 
                  ? "No tagged posts"
                  : "Tagged in ${profile.taggedPosts.length} posts",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(ProfileModel profile) {
    if (profile.socials.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: profile.socials.map((social) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: social.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: social.color.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(social.icon, color: social.color, size: 20),
              onPressed: () async {
                final url = Uri.parse(social.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isMenuOpen) ...[
          // Option 1: Spark
          GestureDetector(
            onTap: () {
              setState(() {
                _isMenuOpen = false;
              });
              _showOptionSelected('Spark');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Spark',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Option 2: Arena
          GestureDetector(
            onTap: () {
              setState(() {
                _isMenuOpen = false;
              });
              _showOptionSelected('Arena');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.teal],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_esports, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Arena',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // Main Toggle Button
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
          backgroundColor: Colors.blueAccent,
          mini: true,
          child: AnimatedRotation(
            turns: _isMenuOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showOptionSelected(String option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$option selected'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
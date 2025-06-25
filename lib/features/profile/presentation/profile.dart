import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/profile/presentation/more_post.dart';
import '../providers/profile_providers.dart';
import '../models/profile_model.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final List<String> tabs = ["Posts", "Stories", "Liked", "Tagged"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      
      body: _buildBody(profileState, selectedTabIndex),
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
        return _buildProfileContent(profileState.profile, selectedTabIndex);
    }
  }

  Widget _buildProfileContent(ProfileModel profile, int selectedTabIndex) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _buildProfileHeader(profile),
          const SizedBox(height: 24),
          _buildAboutSection(profile),
          const SizedBox(height: 24),
          _buildInterestsSection(profile),
          const SizedBox(height: 24),
          _buildHighlightsSection(),
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
  Widget _buildProfileHeader(ProfileModel profile) {
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
                  backgroundImage: NetworkImage(
                    "https://ui-avatars.com/api/?name=${profile.name}&background=random"
                  ),
                ),
              ),  
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
          
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProfileModel profile) {
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit, color: Colors.white),
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      iconSize: 16,
                      padding: EdgeInsets.zero,
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
                : "A dedicated Astronomy enthusiast, pursuing B-tech in ktu university at kerala. I'm curious about the mysteries that are hidden throughout the spacetime fabric and want to explore this universe.",
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(ProfileModel profile) {
    final interests = profile.interests.isNotEmpty 
        ? profile.interests 
        : ["Entrepreneurship", "Business", "Analytics", "Startup", "Astronomy", "Powerlifting", "Basketball"];
    
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

  Widget _buildHighlightsSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Highlights",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHighlightCard(
                  "Why do you think kids are naturally curious about science, but many of us lose that spark as we grow up?",
                  true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildHighlightCard(
                  "Anu, while you're excelling academically, how do you balance that with taking a hands-",
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String text, bool isFirst) {
    return Container(
      height: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFirst ? Color(0xFF1A237E) : Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: isFirst ? null : Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          if (isFirst) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            SizedBox(height: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: isFirst ? 4 : 5,
              overflow: TextOverflow.ellipsis,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          ...profile.posts.take(1).map((post) => _buildSinglePost(post)),          if (profile.posts.length > 1) ...[
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
                  "See more post",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildSinglePost(Post post) {
    DateTime postDate = DateTime.parse(post.createdAt);
    String timeAgo = _getTimeAgo(postDate);
    String username = "Anu"; // Using the name from the image

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
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  "https://ui-avatars.com/api/?name=Anu&background=random"
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
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
              ],
            ),
          ],
          
          // Post actions
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPostAction(Icons.thumb_up_outlined, "261"),
              const SizedBox(width: 20),
              _buildPostAction(Icons.chat_bubble_outline, "12"),
              const SizedBox(width: 20),
              _buildPostAction(Icons.share_outlined, ""),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.bookmark_border, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildPostAction(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        if (count.isNotEmpty) ...[
          SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ],
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

  Widget _buildStoriesContent(ProfileModel profile) {
    if (profile.stories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.auto_stories, color: Colors.grey.shade600, size: 48),
              SizedBox(height: 16),
              Text(
                "No stories yet",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemCount: profile.stories.length,
      itemBuilder: (context, index) {
        final story = profile.stories[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_stories, color: Colors.blue, size: 20),
            ),
            title: Text(
              story.content,
              style: TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _getTimeAgo(DateTime.parse(story.createdAt)),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            onTap: () {},
          ),
        );
      },
    );
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
}
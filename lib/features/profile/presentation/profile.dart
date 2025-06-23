import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/profile/presentation/more_post.dart';
import '../providers/profile_providers.dart';
import '../models/profile_model.dart'; // Make sure this import is correct
import 'package:assistrend/features/auth/providers/auth_provider.dart'; // Make sure this import is correct
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
    // Load user profile on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
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
            SnackBar(content: Text('User not authenticated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(profileState, selectedTabIndex),
    );
  }

  Widget _buildBody(ProfileState profileState, int selectedTabIndex) {
    if (profileState.status == ProfileStatus.loading) {
      return Center(child: CircularProgressIndicator());
    } else if (profileState.status == ProfileStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${profileState.errorMessage}', style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return _buildProfileContent(profileState.profile, selectedTabIndex);
    }
  }

  Widget _buildProfileContent(ProfileModel profile, int selectedTabIndex) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile),
          Divider(color: Colors.grey),
          _buildAboutSection(profile),
          SizedBox(height: 16),
          _buildInterestsSection(),
          SizedBox(height: 16),
          _buildHighlightsSection(),
          SizedBox(height: 16),
          Divider(color: Colors.grey),
          _buildTabBar(selectedTabIndex),
          SizedBox(height: 16),
          _buildSelectedTabContent(profile, selectedTabIndex),
          SizedBox(height: 16),
          _buildSocialLinks(profile),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileModel profile) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              "https://ui-avatars.com/api/?name=${profile.name}&background=random"
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "@${profile.username}",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                Row(
                  children: [
                    Text(
                      "${profile.points} points",
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    if (profile.emoji.isNotEmpty)
                      Text(
                        profile.emoji,
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            profile.about.isNotEmpty 
                ? profile.about 
                : "No about information available",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (profile.badges.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              "Badges",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: profile.badges.map((badge) {
                return Chip(
                  avatar: Icon(Icons.star, color: Colors.amber, size: 16),
                  label: Text(badge.name),
                  backgroundColor: Colors.grey[800],
                  labelStyle: TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    // This could be dynamic from the API if you add interests to your model
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Interests",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChip("Entrepreneurship"),
              _buildChip("Business"),
              _buildChip("Analytics"),
              _buildChip("Startup"),
              _buildChip("Astronomy"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection() {
    // This could be dynamic from the API if you add highlights to your model
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Highlights",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: PageView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildHighlightCard(
                  "Why do you think kids are naturally curious about science, but many of us lose that spark as we grow up?"),
                _buildHighlightCard(
                  "While you're excelling academically, how do you balance that with taking a hands-on approach to learning?"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int selectedTabIndex) {
    return Padding(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No posts yet",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          ...profile.posts.take(1).map((post) => _buildSinglePost(post)),
          if (profile.posts.length > 1) ...[
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeMorePostsPage(),
                    ),
                  );
                },
                child: const Text("See more posts",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSinglePost(Post post) {
    // Format date to display relative time
    DateTime postDate = DateTime.parse(post.createdAt);
    String timeAgo = _getTimeAgo(postDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption.split(' ').take(2).join(' '), // Use first two words as title
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.caption,
            style: TextStyle(color: Colors.white),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (post.imageUrl.isNotEmpty)
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
                        color: Colors.grey[800],
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Experience",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
              SizedBox(width: 8),
              Text("0", style: TextStyle(color: Colors.grey)),
              SizedBox(width: 16),
              Icon(Icons.comment_outlined, color: Colors.grey),
              SizedBox(width: 8),
              Text("0", style: TextStyle(color: Colors.grey)),
              Spacer(),
              Icon(Icons.share_outlined, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildStoriesContent(ProfileModel profile) {
    if (profile.stories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No stories yet",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: profile.stories.length,
      itemBuilder: (context, index) {
        final story = profile.stories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Icon(Icons.auto_stories, color: Colors.blue),
          ),
          title: Text(
            story.content,
            style: TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _getTimeAgo(DateTime.parse(story.createdAt)),
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            // Show full story
          },
        );
      },
    );
  }

  Widget _buildLikedContent(ProfileModel profile) {
    if (profile.likedPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No liked posts",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Liked ${profile.likedPosts.length} posts",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget _buildTaggedContent(ProfileModel profile) {
    if (profile.taggedPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No tagged posts",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Tagged in ${profile.taggedPosts.length} posts",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget _buildSocialLinks(ProfileModel profile) {
    if (profile.socials.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: profile.socials.map((social) {
          return IconButton(
            icon: Icon(social.icon, color: social.color),
            onPressed: () async {
              final url = Uri.parse(social.url);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  // Helper Method: Build Chips for Interests
  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  // Helper Method: Build Highlight Cards
  Widget _buildHighlightCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
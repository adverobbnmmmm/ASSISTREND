import 'package:assistrend_mine/more_post.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Selected tab index
  int selectedTabIndex = 0;

  // Tab labels
  final List<String> tabs = ["Posts", "Stories", "Liked", "Tagged"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/profile_pic.jpg"),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Anu",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          "@anumithral123",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        Row(
                          children: [
                            Icon(Icons.rocket_launch, color: Colors.purple),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_right, color: Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // About Section
            const Padding(
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
                    "A dedicated Astronomy enthusiast, pursuing B-tech in KTU university at Kerala. I'm curious about the mysteries that are hidden throughout the spacetime fabric and want to explore this universe.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interests Section
            Padding(
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
                      _buildChip("Powerlifting"),
                      _buildChip("Basketball"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Highlights Section
            Padding(
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
                            "Why do you think kids are naturally curious about science, but many of us lose that spark as we grow up? What are your thoughts on this, Anu?"),
                        _buildHighlightCard(
                            "Anu, while you're excelling academically, how do you balance that with taking a hands-on approach to learning?"),
                        _buildHighlightCard(
                            "What motivates you to pursue Astronomy, Anu? Is there a specific moment or event that inspired your journey?"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),

            // Tabs Section (Posts, Stories, Liked, Tagged)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  tabs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

            // Posts Section (Dynamic Based on Tab Selection)
            if (selectedTabIndex == 0) _buildPostContent(),
            if (selectedTabIndex == 1)
              _buildPlaceholderContent("Stories Content"),
            if (selectedTabIndex == 2)
              _buildPlaceholderContent("Liked Content"),
            if (selectedTabIndex == 3)
              _buildPlaceholderContent("Tagged Content"),

            const SizedBox(height: 16),

            // Social Profiles Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, color: Colors.white),
                  SizedBox(width: 8),
                  Icon(Icons.facebook, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
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

  // Helper Method: Build Placeholder Content
  Widget _buildPlaceholderContent(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  // Build Post Content
  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildSinglePost(),
          const SizedBox(height: 16),
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
              child: const Text("See more post",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Method: Build Single Post
  Widget _buildSinglePost() {
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
                backgroundImage: AssetImage("assets/profile_pic.jpg"),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Anu",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "3d ago",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Going on vacation! Catch you all in 10 days. No call!!!!!",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/vacation.png",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              Text("261", style: TextStyle(color: Colors.grey)),
              SizedBox(width: 16),
              Icon(Icons.comment_outlined, color: Colors.grey),
              SizedBox(width: 8),
              Text("12", style: TextStyle(color: Colors.grey)),
              Spacer(),
              Icon(Icons.share_outlined, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

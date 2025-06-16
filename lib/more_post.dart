import 'package:flutter/material.dart';

class SeeMorePostsPage extends StatefulWidget {
  const SeeMorePostsPage({super.key});

  @override
  _SeeMorePostsPageState createState() => _SeeMorePostsPageState();
}

class _SeeMorePostsPageState extends State<SeeMorePostsPage>
    with SingleTickerProviderStateMixin {
  int selectedTabIndex = 0;

  final List<String> tabs = ["Posts", "Stories", "Liked", "Tagged"];

  late AnimationController _likeAnimationController;
  late Animation<Color?> _likeColorAnimation;

  bool _isLiked = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("See More Posts"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                      setState(() {
                        selectedTabIndex = index;
                      });
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

            // Dynamic Content Based on Selected Tab
            if (selectedTabIndex == 0) _buildPostContent(),
            if (selectedTabIndex == 1)
              _buildPlaceholderContent("Stories Content"),
            if (selectedTabIndex == 2)
              _buildPlaceholderContent("Liked Content"),
            if (selectedTabIndex == 3)
              _buildPlaceholderContent("Tagged Content"),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildSinglePost(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

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
                children: const [
                  Text(
                    "Anu",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "2d ago",
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
          const Text(
            "Exploring the mountains! 🏔️",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/mountain.jpg",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
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
                      color: _likeColorAnimation.value,
                      size: 28,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text("120", style: TextStyle(color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.comment_outlined, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

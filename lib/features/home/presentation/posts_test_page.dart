import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';

class PostsTestPage extends ConsumerStatefulWidget {
  const PostsTestPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostsTestPage> createState() => _PostsTestPageState();
}

class _PostsTestPageState extends ConsumerState<PostsTestPage> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProvider.notifier).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts with Comments & Likes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(postsProvider.notifier).fetchPosts(),
          ),
        ],
      ),
      body: _buildPostsList(postsState),
    );
  }

  Widget _buildPostsList(PostsState postsState) {
    if (postsState.isLoading && postsState.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (postsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Failed to load posts',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              postsState.error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(postsProvider.notifier).fetchPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (postsState.posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts available',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: postsState.posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: postsState.posts[index]);
      },
    );
  }
}

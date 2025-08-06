import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../providers/posts_provider.dart';
import '../widgets/comments_bottom_sheet.dart';

class PostBottomBar extends ConsumerWidget {
  final Post post;

  const PostBottomBar({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _toggleLike(ref),
            icon: Icon(
              post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              color: post.isLiked ? Colors.blue : Colors.white,
            ),
            label: Text(
              post.likesCount.toString(),
              style: TextStyle(
                color: post.isLiked ? Colors.blue : Colors.white,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showComments(context),
            icon: const Image(
              image: AssetImage('assets/comment.png'),
              color: Colors.white,
              width: 20,
              height: 20,
            ),
            label: Text(
              post.commentsCount.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () => _sharePost(context),
            icon: const Icon(
              Icons.file_upload_outlined,
              color: Colors.white,
            ),
            label: const Text(
              'Share',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _bookmarkPost(context),
            icon: const Icon(
              Icons.bookmark_border_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  void _toggleLike(WidgetRef ref) {
    ref.read(postsProvider.notifier).toggleLike(post.id);
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: post.id,
        postUsername: post.username ?? 'Anonymous',
      ),
    );
  }

  void _sharePost(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  void _bookmarkPost(BuildContext context) {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark functionality coming soon!'),
      ),
    );
  }
}

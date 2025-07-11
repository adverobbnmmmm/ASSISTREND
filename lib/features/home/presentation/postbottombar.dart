import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/likes_service.dart';
import '../services/comments_service.dart';
import '../widgets/comments_bottom_sheet.dart';

class PostBottomBar extends StatefulWidget {
  const PostBottomBar({
    super.key,
    this.post,
  });

  final Post? post;

  @override
  State<PostBottomBar> createState() => _PostBottomBarState();
}

class _PostBottomBarState extends State<PostBottomBar> {
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isLikeLoading = false;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize likes state from post
    if (widget.post != null) {
      _isLiked = widget.post!.isLiked;
      _likesCount = widget.post!.likesCount;
      _loadCommentsCount();
    }
  }

  Future<void> _loadCommentsCount() async {
    if (widget.post == null) return;
    
    try {
      final comments = await CommentsService.getComments(widget.post!.id);
      setState(() {
        _commentsCount = comments.length;
      });
    } catch (e) {
      // Silently fail for comments count
      debugPrint('Failed to load comments count: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (widget.post == null || _isLikeLoading) return;
    
    setState(() {
      _isLikeLoading = true;
    });
    
    try {
      if (_isLiked) {
        // Unlike the post
        await LikesService.removeLike(widget.post!.id);
        setState(() {
          _isLiked = false;
          _likesCount = _likesCount > 0 ? _likesCount - 1 : 0;
        });
      } else {
        // Like the post
        await LikesService.addLike(widget.post!.id);
        setState(() {
          _isLiked = true;
          _likesCount = _likesCount + 1;
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isLiked ? 'unlike' : 'like'} post'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: _isLikeLoading ? null : _toggleLike,
            icon: _isLikeLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color: _isLiked ? Colors.blue : Colors.white,
                  ),
            label: Text(
              '$_likesCount',
              style: TextStyle(
                color: _isLiked ? Colors.blue : Colors.white,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              // Show comments bottom sheet
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CommentsBottomSheet(
                  post: widget.post!,
                  onCommentAdded: () {
                    // This will be called immediately when a comment is added
                    _loadCommentsCount();
                  },
                ),
              );
              
              // Also refresh when the sheet is closed if comments were added
              if (result == true) {
                _loadCommentsCount();
              }
            },
            icon: const Image(
              image: AssetImage('assets/comment.png'),
              color: Colors.white,
              width: 20,
              height: 20,
            ),
            label: Text(
              '$_commentsCount',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.file_upload_outlined,
              color: Colors.white,
            ),
            label: const Text(
              '20',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.bookmark_border_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

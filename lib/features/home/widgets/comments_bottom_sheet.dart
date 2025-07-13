import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/comments_provider.dart';
import 'comment_tile.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final int postId;
  final String postUsername;

  const CommentsBottomSheet({
    Key? key,
    required this.postId,
    required this.postUsername,
  }) : super(key: key);

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Fetch comments when the sheet opens
    // Use Timer to delay the API call as ref is not available in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(commentsProvider(widget.postId).notifier).fetchComments(widget.postId);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsProvider(widget.postId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Comments list
          Expanded(
            child: commentsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : commentsState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${commentsState.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(commentsProvider(widget.postId).notifier)
                                  .fetchComments(widget.postId),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : commentsState.comments.isEmpty
                        ? const Center(
                            child: Text('No comments yet. Be the first to comment!'),
                          )
                        : ListView.builder(
                            itemCount: commentsState.comments.length,
                            itemBuilder: (context, index) {
                              return CommentTile(
                                comment: commentsState.comments[index],
                              );
                            },
                          ),
          ),

          // Add comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      ref
          .read(commentsProvider(widget.postId).notifier)
          .addComment(widget.postId, commentText);
      _commentController.clear();
      _focusNode.unfocus();
    }
  }
}
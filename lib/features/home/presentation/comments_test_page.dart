import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/social_service.dart';
import '../providers/comments_provider.dart';
import '../../../shared/utils/storage.dart';

class CommentsTestPage extends ConsumerStatefulWidget {
  const CommentsTestPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CommentsTestPage> createState() => _CommentsTestPageState();
}

class _CommentsTestPageState extends ConsumerState<CommentsTestPage> {
  final TextEditingController _postIdController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int? _currentPostId;
  String _output = '';

  @override
  Widget build(BuildContext context) {
    final commentsState = _currentPostId != null 
        ? ref.watch(commentsProvider(_currentPostId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Post ID input
            TextField(
              controller: _postIdController,
              decoration: const InputDecoration(
                labelText: 'Post ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Load Comments button
            ElevatedButton(
              onPressed: _loadComments,
              child: const Text('Load Comments'),
            ),
            const SizedBox(height: 16),
            
            // Comment input
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'New Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Add Comment button
            ElevatedButton(
              onPressed: _addComment,
              child: const Text('Add Comment'),
            ),
            const SizedBox(height: 16),
            
            // Test Direct API button
            ElevatedButton(
              onPressed: _testDirectAPI,
              child: const Text('Test Direct API'),
            ),
            const SizedBox(height: 16),
            
            // Output area
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Comments list
            Expanded(
              child: commentsState != null
                  ? _buildCommentsList(commentsState)
                  : const Center(child: Text('Enter a Post ID and load comments')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(CommentsState commentsState) {
    if (commentsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (commentsState.error != null) {
      return Center(
        child: Text(
          'Error: ${commentsState.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    
    if (commentsState.comments.isEmpty) {
      return const Center(child: Text('No comments found'));
    }
    
    return ListView.builder(
      itemCount: commentsState.comments.length,
      itemBuilder: (context, index) {
        final comment = commentsState.comments[index];
        return Card(
          child: ListTile(
            title: Text(comment.comment),
            subtitle: Text('By: ${comment.username} at ${comment.createdAt}'),
          ),
        );
      },
    );
  }

  void _loadComments() {
    final postIdText = _postIdController.text.trim();
    if (postIdText.isEmpty) {
      setState(() {
        _output = 'Please enter a Post ID';
      });
      return;
    }
    
    final postId = int.tryParse(postIdText);
    if (postId == null) {
      setState(() {
        _output = 'Invalid Post ID';
      });
      return;
    }
    
    setState(() {
      _currentPostId = postId;
      _output = 'Loading comments for post $postId...';
    });
    
    ref.read(commentsProvider(postId).notifier).fetchComments(postId);
  }

  void _addComment() async {
    if (_currentPostId == null) {
      setState(() {
        _output = 'Please load comments first';
      });
      return;
    }
    
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      setState(() {
        _output = 'Please enter a comment';
      });
      return;
    }
    
    try {
      setState(() {
        _output = 'Adding comment...';
      });
      
      await ref.read(commentsProvider(_currentPostId!).notifier)
          .addComment(_currentPostId!, commentText);
      
      _commentController.clear();
      
      setState(() {
        _output = 'Comment added successfully!';
      });
    } catch (e) {
      setState(() {
        _output = 'Error adding comment: $e';
      });
    }
  }

  void _testDirectAPI() async {
    try {
      setState(() {
        _output = 'Testing direct API...';
      });
      
      final postId = int.tryParse(_postIdController.text.trim()) ?? 1;
      final userId = await Storage.getUserId() ?? 1;
      
      // Test get comments
      final comments = await SocialService.getComments(postId);
      
      setState(() {
        _output = 'Direct API test:\n'
            'Post ID: $postId\n'
            'User ID: $userId\n'
            'Comments found: ${comments.length}\n'
            'Comments: ${comments.map((c) => c.comment).join(', ')}';
      });
    } catch (e) {
      setState(() {
        _output = 'Direct API test failed: $e';
      });
    }
  }
}

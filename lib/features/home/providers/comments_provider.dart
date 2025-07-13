import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment_model.dart';
import '../services/social_service.dart';
import '../../../shared/utils/storage.dart';
import 'posts_provider.dart';

// Comments state
class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Comments notifier
class CommentsNotifier extends StateNotifier<CommentsState> {
  final Ref ref;
  
  CommentsNotifier(this.ref) : super(CommentsState());

  Future<void> fetchComments(int postId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final comments = await SocialService.getComments(postId);
      state = state.copyWith(
        comments: comments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addComment(int postId, String comment) async {
    try {
      final userId = await Storage.getUserId();
      if (userId == null) {
        state = state.copyWith(error: 'User not authenticated');
        return;
      }

      final success = await SocialService.addComment(postId, userId, comment);
      if (success) {
        // Refresh comments after adding new one
        await fetchComments(postId);
        // Trigger posts refresh to update comment count
        ref.read(postsProvider.notifier).fetchPosts();
      } else {
        state = state.copyWith(error: 'Failed to add comment');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clear() {
    state = CommentsState();
  }
}

// Comments provider factory
final commentsProvider = StateNotifierProvider.family<CommentsNotifier, CommentsState, int>((ref, postId) {
  return CommentsNotifier(ref);
});

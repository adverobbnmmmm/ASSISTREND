import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../../../core/network/api_service.dart';
import '../services/social_service.dart';
import '../../../shared/utils/storage.dart';

// Posts state
class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Posts notifier
class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier() : super(PostsState());

  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final postsData = await ApiService.getPostsFeed();
      final posts = postsData.map((postJson) => Post.fromJson(postJson)).toList();
      
      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleLike(int postId) async {
    try {
      final userId = await Storage.getUserId();
      if (userId == null) {
        state = state.copyWith(error: 'User not authenticated');
        return;
      }

      // Find the post and update optimistically
      final postIndex = state.posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;

      final post = state.posts[postIndex];
      final isCurrentlyLiked = post.isLiked;
      
      // Optimistic update
      final updatedPost = post.copyWith(
        isLiked: !isCurrentlyLiked,
        likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
      );

      final updatedPosts = List<Post>.from(state.posts);
      updatedPosts[postIndex] = updatedPost;
      state = state.copyWith(posts: updatedPosts);

      // Make API call
      bool success;
      if (isCurrentlyLiked) {
        success = await SocialService.unlikePost(postId, userId);
      } else {
        success = await SocialService.likePost(postId, userId);
      }

      if (!success) {
        // Revert optimistic update if API call failed
        updatedPosts[postIndex] = post;
        state = state.copyWith(posts: updatedPosts, error: 'Failed to update like');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      // Revert optimistic update
      await fetchPosts();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Posts provider
final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});

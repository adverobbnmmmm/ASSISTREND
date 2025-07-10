import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../../../core/network/api_service.dart';

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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Posts provider
final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});

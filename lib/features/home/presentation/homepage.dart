import 'package:assistrend/features/home/presentation/appbar.dart';
import 'package:assistrend/features/home/presentation/carousel.dart';
import 'package:assistrend/features/home/presentation/connect.dart';
import 'package:assistrend/features/home/presentation/posts.dart';
import 'package:assistrend/features/home/services/audio_player_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:assistrend/features/home/providers/posts_provider.dart';
import 'messenger.dart';

final ValueNotifier<bool> showContainer = ValueNotifier<bool>(false);
void toggleContainer() {
  showContainer.value = !showContainer.value;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void dispose() {
    // Clean up audio player when page is disposed
    AudioPlayerService.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      print('Logout initiated');
      
      print('Calling logout on auth provider');
      // Use the auth provider to logout
      await ref.read(authProvider.notifier).logout();
      
      print('Logout completed');
      
      // Small delay to ensure state is updated
      await Future.delayed(Duration(milliseconds: 100));
      
      // Navigate directly without closing any dialogs
      if (context.mounted) {
        print('Navigating to opening screen');
        // Navigate to opening screen to trigger proper auth flow
        context.go('/');
      }
    } catch (e) {
      print('Logout error: $e');
      // Even if logout fails, clear local state and navigate
      if (context.mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user info from auth state
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    
    // Watch posts state
    final postsState = ref.watch(postsProvider);
    
    // Fetch posts when the widget is built for the first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postsState.posts.isEmpty && !postsState.isLoading) {
        ref.read(postsProvider.notifier).fetchPosts();
      }
    });
    
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff181a1c),
              title: const Text('Assistrend'),
              actions: [
                if (userId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text('User ID: $userId', style: TextStyle(fontSize: 12)),
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _handleLogout(context, ref),
                  tooltip: 'Logout',
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report),
                  onPressed: () => context.go('/debug-logout'),
                  tooltip: 'Debug',
                ),
                IconButton(
                  icon: const Icon(Icons.science),
                  onPressed: () => context.go('/simple-logout-test'),
                  tooltip: 'Simple Test',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(postsProvider.notifier).fetchPosts(),
                  tooltip: 'Refresh Posts',
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => context.go('/comments-test'),
                  tooltip: 'Test Comments',
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(children: [
                  const AppBarwidget(),
                  Expanded(
                    child: _buildPostsList(postsState),
                  ),
                ]),
                const ConnectButton(),
                ValueListenableBuilder<bool>(
                    valueListenable: showContainer,
                    builder: (context, value, _) {
                      return Messenger(
                        isSidebaropened: showContainer.value,
                      );
                    }),
              ],
            ),
            backgroundColor: const Color(0xff181a1c)));
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
            Text(
              'Failed to load posts',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              postsState.error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (postsState.posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts available',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index == 0) {
          return const CarouselSlidebar();
        } else {
          final postIndex = index - 1;
          if (postIndex < postsState.posts.length) {
            return AppPosts(post: postsState.posts[postIndex]);
          } else {
            // Fallback for extra items or loading indicator
            return const SizedBox.shrink();
          }
        }
      },
      itemCount: postsState.posts.length + 1, // +1 for carousel
    );
  }
}

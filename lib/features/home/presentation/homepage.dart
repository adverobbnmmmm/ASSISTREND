import 'package:assistrend/features/home/presentation/appbar.dart';
import 'package:assistrend/features/home/presentation/connect.dart';
import 'package:assistrend/features/home/presentation/posts.dart';
import 'package:assistrend/features/home/services/audio_player_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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


  @override
  Widget build(BuildContext context) {
    // Get user info from auth state (only used by the commented-out debug AppBar)
    // final authState = ref.watch(authProvider);
    // final userId = authState.userId;

    // Watch posts state
    final postsState = ref.watch(postsProvider);
    
    // Fetch posts once on first mount. hasFetched prevents re-triggering on
    // every rebuild that follows an error or empty state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!postsState.hasFetched && !postsState.isLoading) {
        ref.read(postsProvider.notifier).fetchPosts();
      }
    });
    
    return SafeArea(
        child: Scaffold(
            // Debug top bar commented out — the original "Welcome" bar
            // (AppBarwidget, below in the body) is used instead.
            /*
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
            */
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not load posts',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                postsState.error!,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5EFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => ref.read(postsProvider.notifier).fetchPosts(),
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
        if (index < postsState.posts.length) {
          return AppPosts(post: postsState.posts[index]);
        } else {
          // Fallback for extra items or loading indicator
          return const SizedBox.shrink();
        }
      },
      itemCount: postsState.posts.length,
    );
  }
}

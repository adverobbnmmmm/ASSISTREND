import 'package:assistrend/features/home/presentation/appbar.dart';
import 'package:assistrend/features/home/presentation/carousel.dart';
import 'package:assistrend/features/home/presentation/connect.dart';
import 'package:assistrend/features/home/presentation/posts.dart';
import 'package:assistrend/core/network/api_service.dart';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'messenger.dart';

final ValueNotifier<bool> showContainer = ValueNotifier<bool>(false);
void toggleContainer() {
  showContainer.value = !showContainer.value;
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      
      // Use the auth provider to logout
      await ref.read(authProvider.notifier).logout();
      
      // Close loading dialog and navigate to login
      if (context.mounted) {
        Navigator.of(context).pop(); // Close dialog
        context.go('/login');
      }
    } catch (e) {
      // Handle any errors
      if (context.mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user info from auth state
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    
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
              ],
            ),
            body: Stack(
              children: [
                Column(children: [
                  const AppBarwidget(),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const CarouselSlidebar();
                        } else {
                          return const AppPosts(
                              img:
                                  "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500");
                        }
                      },
                      itemCount: 10,
                    ),
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
}

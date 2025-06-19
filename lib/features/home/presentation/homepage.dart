import 'package:assistrend/features/home/presentation/appbar.dart';
import 'package:assistrend/features/home/presentation/carousel.dart';
import 'package:assistrend/features/home/presentation/connect.dart';
import 'package:assistrend/features/home/presentation/posts.dart';
import 'package:assistrend/core/network/api_service.dart';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';

import 'messenger.dart';

final ValueNotifier<bool> showContainer = ValueNotifier<bool>(false);
void toggleContainer() {
  showContainer.value = !showContainer.value;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      
      // Get refresh token
      final refreshToken = await Storage.getRefreshToken();
      
      // Call logout API if token exists
      if (refreshToken != null) {
        try {
          await ApiService.logout(refreshToken);
        } catch (e) {
          print('Logout API error: $e');
          // Continue with local logout even if API call fails
        }
      }
      
      // Clear all tokens
      await Storage.clearAllTokens();
      
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
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff181a1c),
              title: const Text('Assistrend'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _handleLogout(context),
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

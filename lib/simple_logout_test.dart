import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/providers/auth_provider.dart';

class SimpleLogoutTest extends ConsumerWidget {
  const SimpleLogoutTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Logout Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Simple logout test
                try {
                  print('Starting simple logout test');
                  await ref.read(authProvider.notifier).logout();
                  print('Logout completed, navigating...');
                  
                  if (context.mounted) {
                    context.go('/login');
                  }
                } catch (e) {
                  print('Simple logout error: $e');
                }
              },
              child: const Text('Test Simple Logout'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Check current auth status
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('access_token');
                final userId = prefs.getInt('user_id');
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Current Auth Status'),
                    content: Text('Token: ${token != null ? 'Present' : 'None'}\nUser ID: $userId'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Check Auth Status'),
            ),
          ],
        ),
      ),
    );
  }
}

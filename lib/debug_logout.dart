import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugLogout extends StatelessWidget {
  const DebugLogout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('access_token');
                final userId = prefs.getString('user_id');
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Auth Status'),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('access_token');
                await prefs.remove('refresh_token');
                await prefs.remove('user_id');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tokens cleared')),
                );
              },
              child: const Text('Clear Tokens'),
            ),
          ],
        ),
      ),
    );
  }
}

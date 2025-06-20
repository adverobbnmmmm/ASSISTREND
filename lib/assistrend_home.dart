import 'package:flutter/material.dart';
import 'features/auth/presentation/assistrend_login.dart';
import 'core/network/api_service.dart';
import 'shared/utils/storage.dart';
import 'package:go_router/go_router.dart';
class AssistrendHome extends StatefulWidget {
  @override
  _AssistrendHomeState createState() => _AssistrendHomeState();
}

class _AssistrendHomeState extends State<AssistrendHome> {
  String? _username = "User";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await Storage.getToken();
    print('DEBUG: Token in home screen: $token');
    if (token != null) {
      try {
        final profile = await ApiService.getProfile(token);
        setState(() {
          _username = profile['username'];
          _isLoading = false;
        });
      } catch (e) {
        print('DEBUG: Error loading profile: $e');
        _handleLogout();
      }
    } else {
      print('DEBUG: No token found in home screen');
      _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    final token = await Storage.getToken();
    print('DEBUG: Logging out with token: $token');
    if (token != null) {
      try {
        await ApiService.logout(token);
        print('DEBUG: Logout API call successful');
      } catch (e) {
        print('DEBUG: Error during logout API call: $e');
      }
    }
    await Storage.clearToken();
    final checkToken = await Storage.getToken();
    print('DEBUG: Token after clearToken: $checkToken');
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Assistrend'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $_username!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildFeatureCard(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      // Navigate to profile screen
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.help,
                    title: 'Help',
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
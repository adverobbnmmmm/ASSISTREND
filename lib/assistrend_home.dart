import 'package:flutter/material.dart';
import 'assistrend_login.dart';
import 'services/api_service.dart';
import 'utils/storage.dart';

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
    if (token != null) {
      try {
        final profile = await ApiService.getProfile(token);
        setState(() {
          _username = profile['username'];
          _isLoading = false;
        });
      } catch (e) {
        _handleLogout();
      }
    } else {
      _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    final token = await Storage.getToken();
    if (token != null) {
      await ApiService.logout(token);
    }
    await Storage.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AssistrendLogin()),
    );
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
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Profile'),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Change Profile Picture',
            onTap: () {
              print('Change Profile Picture tapped');
            },
          ),
          _buildSettingsItem(
            icon: Icons.edit_outlined,
            title: 'Edit Username',
            onTap: () {
              print('Edit Username tapped');
            },
          ),
          _buildSettingsItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              print('Edit Profile tapped');
            },
          ),

          _buildSectionHeader('Settings'),
          _buildSettingsItem(
            icon: Icons.home_outlined,
            title: 'Home Feed Preference',
            onTap: () {
              print('Home Feed Preference tapped');
            },
          ),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {
              print('Notification tapped');
            },
          ),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy and Data',
            onTap: () {
              print('Privacy and Data tapped');
            },
          ),

          _buildSectionHeader('Account'),
          _buildSettingsItem(
            icon: Icons.logout_outlined,
            title: 'Log Out',
            onTap: () {
              _showLogOutDialog(context);
            },
          ),
          _buildSettingsItem(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            onTap: () {
              _showDeleteAccountDialog(context);
            },
            isDestructive: true,
          ),

          _buildSectionHeader('Support'),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Support',
            onTap: () {
              print('Support tapped');
            },
          ),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              print('About tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color:
              isDestructive
                  ? Colors.red.withValues(alpha: 0.7)
                  : Colors.white54,
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey[900],
        hoverColor: Colors.grey[800],
      ),
    );
  }

  // Widget _buildDivider() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 16.0),
  //     height: 1,
  //     color: Colors.grey[800],
  //   );
  // }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
          title: const Text('Log Out', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('User logged out');
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('Account deletion requested');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

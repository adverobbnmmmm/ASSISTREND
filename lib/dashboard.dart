import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'main.dart';

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1A3CDE),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.home_filled),
          onPressed: () {
            _showHomeDialog(context);
          },
        ),
      ),
      body: const UserListView(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pop(context);
                // You can add navigation to login screen here
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showHomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('User Mode'),
          content: const Text('Are you sure you want to change to User Mode?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).userMode();
                Navigator.pop(context);
                // navigation to home screen
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

// User List View with Pagination and Lazy Loading
class UserListView extends StatefulWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).fetchUsers(loadMore: true);
      }
    });
    // Fetch initial users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return userProvider.isLoading && userProvider.users.isEmpty
        ? const Center(child: SpinKitCircle(color: Color(0xFF1A3CDE)))
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount:
                userProvider.users.length + (userProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == userProvider.users.length) {
                return const Center(
                  child: SpinKitCircle(color: Color(0xFF1A3CDE)),
                );
              }
              return UserCard(user: userProvider.users[index], index: index);
            },
          );
  }
}

// User Card with Animation
class UserCard extends StatefulWidget {
  final User user;
  final int index;

  const UserCard({Key? key, required this.user, required this.index})
    : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_controller),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Theme.of(context).colorScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.user.profilePicture),
              radius: 20,
              onBackgroundImageError: (error, stackTrace) {
                print('Image load error: $error');
              },
            ),
            title: Text(
              widget.user.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              widget.user.location,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Bio', widget.user.bio, context),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Social Links',
                      widget.user.socialLinks.join(', '),
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Reported Posts',
                      widget.user.reportedPosts.length.toString(),
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Engagement',
                      widget.user.engagementSummary.toString(),
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Connection',
                      widget.user.connection.summary,
                      context,
                    ),
                    _buildInfoRow(
                      'Anonymous',
                      widget.user.connection.isAnonymous.toString(),
                      context,
                    ),
                    _buildInfoRow(
                      'Initiated',
                      widget.user.connection.initiationTimestamp,
                      context,
                    ),
                    _buildInfoRow(
                      'Responded',
                      widget.user.connection.respondTimestamp,
                      context,
                    ),
                    _buildInfoRow(
                      'Feedback',
                      widget.user.connection.feedback,
                      context,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Gamification',
                      widget.user.gamification.taskStatus,
                      context,
                    ),
                    ...widget.user.gamification.answers.map(
                      (qa) => _buildInfoRow(
                        'Q: ${qa.question}',
                        qa.answer,
                        context,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Nickname',
                      widget.user.additionalProfile.nickname,
                      context,
                    ),
                    _buildInfoRow(
                      'Audio Summary',
                      widget.user.additionalProfile.audioSummary,
                      context,
                    ),
                    _buildInfoRow(
                      'Highlights',
                      widget.user.additionalProfile.highlightData,
                      context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

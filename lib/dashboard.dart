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
        backgroundColor: const Color.fromARGB(255, 14, 30, 110),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: UserSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Admin Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings screen (placeholder)
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Implement logout logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: const UserListView(),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Filter Users',
            style: TextStyle(fontSize: 18), // Smaller title font
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            8,
          ), // Reduced title padding
          contentPadding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            8,
          ), // Reduced content padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: 'all',
                isDense: true, // Compact dropdown
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).setFilters({'status': value});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            8,
            0,
            8,
            8,
          ), // Reduced actions padding
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
        ? const Center(child: SpinKitCircle(color: Color(0xFF2E4EF6)))
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount:
                userProvider.users.length + (userProvider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == userProvider.users.length) {
                return const Center(
                  child: SpinKitCircle(color: Color(0xFF2E4EF6)),
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

// Search Delegate
class UserSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setSearchQuery(query);
    return const UserListView();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}

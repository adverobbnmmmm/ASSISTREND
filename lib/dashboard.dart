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
              decoration: BoxDecoration(color: const Color(0xFF1A3CDE)),
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
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
          title: const Text('Filter Users', style: TextStyle(fontSize: 18)),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: 'all',
                isDense: true,
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
          actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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

// Search Delegate
// Fixed Search Delegate
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
    // Defer the search query update to avoid build phase error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).setSearchQuery(query);
    });

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Filter users based on current query for immediate display
        final filteredUsers = _getFilteredUsers(userProvider, query);

        if (filteredUsers.isEmpty && query.isNotEmpty) {
          return const Center(
            child: Text(
              'No users found',
              style: TextStyle(
                color: Color.fromARGB(184, 255, 255, 255), // Pure red
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return UserCard(user: filteredUsers[index], index: index);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Get filtered users without calling setSearchQuery during build
        final filteredUsers = _getFilteredUsers(userProvider, query);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  filteredUsers[index].profilePicture,
                ),
                radius: 20,
                onBackgroundImageError: (error, stackTrace) {
                  print('Image load error: $error');
                },
              ),
              title: Text(filteredUsers[index].fullName),
              subtitle: Text(filteredUsers[index].location),
              onTap: () {
                query = filteredUsers[index].fullName;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  // Helper method to filter users without triggering provider updates
  List<User> _getFilteredUsers(UserProvider userProvider, String searchQuery) {
    if (searchQuery.trim().isEmpty) {
      return userProvider.users;
    }

    final queryLower = searchQuery.trim().toLowerCase();
    return userProvider.users.where((user) {
      final fullNameLower = user.fullName.toLowerCase();
      final bioLower = user.bio.toLowerCase();
      final locationLower = user.location.toLowerCase();
      final nicknameLower = user.additionalProfile.nickname.toLowerCase();

      return fullNameLower.contains(queryLower) ||
          bioLower.contains(queryLower) ||
          locationLower.contains(queryLower) ||
          nicknameLower.contains(queryLower);
    }).toList();
  }
}

// Alternative: Simpler Search Results Widget
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Color.fromARGB(255, 247, 247, 247),
                ),
                SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(color: Color.fromARGB(255, 247, 247, 247)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: userProvider.users.length,
          itemBuilder: (context, index) {
            return UserCard(user: userProvider.users[index], index: index);
          },
        );
      },
    );
  }
}

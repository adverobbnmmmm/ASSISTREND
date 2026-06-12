import 'package:flutter/material.dart';
import 'package:assistrend/core/network/api_service.dart';
import 'mock_call_screen.dart';

class ChampionHubPage extends StatefulWidget {
  const ChampionHubPage({super.key});

  @override
  State<ChampionHubPage> createState() => _ChampionHubPageState();
}

class _ChampionHubPageState extends State<ChampionHubPage> {
  List<dynamic> _matchingUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMatchingUsers();
  }

  Future<void> _fetchMatchingUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getChampionUsers();
      if (mounted) {
        setState(() {
          _matchingUsers = response['users'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load matching users: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12161C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text(
          'Community Champion Hub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchMatchingUsers,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1D5EFF)))
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : _matchingUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildUsersList(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D5EFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _fetchMatchingUsers,
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.white.withOpacity(0.2), size: 80),
            const SizedBox(height: 24),
            const Text(
              'No Matching Members Yet',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Currently there are no community members sharing your specialized domains. Keep checking back!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _matchingUsers.length,
      itemBuilder: (context, index) {
        final user = _matchingUsers[index];
        final name = user['name'] ?? 'Anonymous';
        final emoji = user['emoji'] ?? '👤';
        final bio = user['bio'] ?? '';
        final location = user['location'] ?? 'Remote';
        final interests = List<String>.from(user['interests'] ?? []);

        return Card(
          color: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white12, width: 1),
          ),
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar / Emoji
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Shared Interests chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D5EFF).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1D5EFF).withOpacity(0.3), width: 1),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(
                                color: Color(0xFF5E8BFF),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Call Action Button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MockCallScreen(
                          userName: name,
                          userEmoji: emoji,
                          userLocation: location,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call, color: Color(0xFF1D5EFF), size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1D5EFF).withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

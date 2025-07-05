import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/providers/chat_provider.dart';
import '../../chat/domain/models/chat_models.dart';

/// This widget displays the list of friends and groups the user can chat with.
class ChatHomePage extends ConsumerWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that loads chat data.
    final chatAsync = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Back to main home page
          },
        ),
      ),
      body: chatAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          // NO .fromJson() here—these are already objects
          final friends = data['friends'] as List<Friend>;
          final groups = data['groups'] as List<ChatGroup>;

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(chatProvider);
            },
            child: ListView(
              children: [
                if (friends.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Friends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...friends.map(
                    (friend) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(friend.username),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped ${friend.username}')),
                        );
                        // Later: navigate to chat page
                      },
                    ),
                  ),
                ],
                if (groups.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...groups.map(
                    (group) => ListTile(
                      leading: const Icon(Icons.group),
                      title: Text(group.name),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped ${group.name}')),
                        );
                        // Later: navigate to group chat
                      },
                    ),
                  ),
                ],
                // Optionally, a message if there are no friends or groups
                if (friends.isEmpty && groups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No chats available yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

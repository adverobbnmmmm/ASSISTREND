import 'package:assistrend/features/home/main/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/providers/chat_provider.dart';
import '../../chat/domain/models/chat_models.dart';

/// Widget displaying the list of friends and groups.
class ChatHomePage extends ConsumerWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the chatProvider to get async data.
    final chatAsync = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: chatAsync.when(
        // While loading, show spinner
        loading: () => const Center(child: CircularProgressIndicator()),

        // If error, display error message
        error: (err, stack) => Center(child: Text('Error: $err')),

        // If data loaded
        data: (data) {
          final friends = data['friends'] as List<Friend>;
          final groups = data['groups'] as List<ChatGroup>;

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(chatProvider);
            },
            child: ListView(
              children: [
                // Show Friends if any
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
                      leading:
                          friend.profilePicture != null &&
                              friend.profilePicture!.isNotEmpty
                          ? CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                // Use the absolute URL
                                'http://10.0.2.2:8002${friend.profilePicture}',
                              ),
                            )
                          : const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.person),
                            ),
                      title: Text(
                        friend.name.isNotEmpty ? friend.name : 'Unnamed',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        // TODO: navigate to chat page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped ${friend.name}')),
                        );
                      },
                    ),
                  ),
                ],

                // Show Groups if any
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
                      leading: const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.group),
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        // TODO: navigate to group chat
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped ${group.name}')),
                        );
                      },
                    ),
                  ),
                ],

                // Show fallback if no friends or groups
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

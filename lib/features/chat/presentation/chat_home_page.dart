import 'dart:convert';
import 'package:assistrend/features/chat/utils/chat_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';
import 'package:assistrend/shared/services/auth_helper.dart'; // for TokenManager
import '../application/providers/chat_provider.dart';
import '../../chat/domain/models/chat_models.dart';

/// Widget displaying the list of friends and groups.
class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({super.key});

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  NotificationsSocket? socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    final token = await TokenManager.ensureValidToken();
    if (token == null) {
      print("❌ No valid JWT token available.");
      return;
    }

    NotificationsSocket.initialize(token);
    socket = NotificationsSocket.instance!;
    socket!.stream.listen((event) {
      print("📩 WebSocket message: $event");

      try {
        final decoded = jsonDecode(event);
        if (decoded['type'] == 'connection_established') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Connected to WebSocket")),
          );
        }

        // You can also listen to other types here (e.g., messages)
        // if (decoded['type'] == 'new_one_to_one_message') { ... }
      } catch (e) {
        print("❌ Failed to decode WebSocket message: $e");
      }
    });
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: chatAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final friends = data['friends'] as List<Friend>;
          final groups = data['groups'] as List<ChatGroup>;

          return RefreshIndicator(
            onRefresh: () async {
              await ChatCache.clear();
              ref.invalidate(chatProvider);
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
                      leading:
                          friend.profilePicture != null &&
                              friend.profilePicture!.isNotEmpty
                          ? CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
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
                        context.push(
                          '/chat/friend/${friend.id}',
                          extra: {
                            'friendId': friend.id,
                            'friendName': friend.name,
                          },
                        );
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
                      leading: const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.group),
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        context.push(
                          '/chat/group/${group.id}',
                          extra: {'groupId': group.id, 'groupName': group.name},
                        );
                      },
                    ),
                  ),
                ],
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

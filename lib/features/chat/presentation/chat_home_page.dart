import 'dart:convert';
import 'package:assistrend/features/chat/utils/chat_cache.dart';
import 'package:assistrend/features/chat/utils/message_cache.dart';
import 'package:assistrend/shared/services/auth_helper.dart';
import 'package:assistrend/features/chat/domain/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:go_router/go_router.dart';
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';
import '../application/providers/chat_provider.dart';
import '../../chat/domain/models/chat_models.dart';
import 'package:http/http.dart' as http;

/// Widget displaying the list of friends and groups.
class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({super.key});

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  NotificationsSocket? socket;
  final Map<int, int> _friendUnreadCounts = {};
  final Map<int, int> _groupUnreadCounts = {};

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _fetchAndCacheMissedMessages();
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
      } catch (e) {
        print("❌ Failed to decode WebSocket message: $e");
      }
    });
  }

  Future<void> _fetchAndCacheMissedMessages() async {
    final token = await TokenManager.ensureValidToken();
    final userId = await Storage.getUserId();
    if (token == null || userId == null) return;

    final uri = Uri.parse('http://10.0.2.2:8002/api/missed-messages/');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List oneToOneMessages = data['one_to_one_messages'];
      final List groupMessages = data['group_messages'];

      for (var msg in oneToOneMessages) {
        final friendId = msg['sender_id'];
        final oldMessages = await MessageCache.loadFriendMessages(friendId, userId);
        final exists = oldMessages.any((m) => m.id == msg['id']);
        if (!exists) {
          oldMessages.add(ChatMessage(
            id: msg['id'],
            senderId: friendId,
            receiverId: userId,
            content: msg['message'] ?? '',
            timestamp: DateTime.parse(msg['timestamp']),
            isMe: false,
            imageUrl: msg['image'],
          ));
          await MessageCache.saveFriendMessages(friendId, oldMessages);
          _friendUnreadCounts.update(friendId, (v) => v + 1, ifAbsent: () => 1);
        }
      }

      for (var msg in groupMessages) {
        final groupId = msg['group_id'];
        final oldMessages = await MessageCache.loadGroupMessages(groupId, userId);
        final exists = oldMessages.any((m) => m.id == msg['id']);
        if (!exists) {
          oldMessages.add(ChatMessage(
            id: msg['id'],
            senderId: msg['sender_id'],
            groupId: groupId,
            content: msg['message'] ?? '',
            timestamp: DateTime.parse(msg['timestamp']),
            isMe: false,
            imageUrl: msg['image'],
          ));
          await MessageCache.saveGroupMessages(groupId, oldMessages);
          _groupUnreadCounts.update(groupId, (v) => v + 1, ifAbsent: () => 1);
        }
      }

      if (mounted) {
        setState(() {});
      }
    } else {
      print("❌ Failed to fetch missed messages: ${response.statusCode}");
    }
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
                      leading: Stack(
                        children: [
                          friend.profilePicture != null && friend.profilePicture!.isNotEmpty
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
                          if (_friendUnreadCounts[friend.id] != null)
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  _friendUnreadCounts[friend.id].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                      title: Text(
                        friend.name.isNotEmpty ? friend.name : 'Unnamed',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        setState(() => _friendUnreadCounts.remove(friend.id));
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
                      leading: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.group),
                          ),
                          if (_groupUnreadCounts[group.id] != null)
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  _groupUnreadCounts[group.id].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        setState(() => _groupUnreadCounts.remove(group.id));
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

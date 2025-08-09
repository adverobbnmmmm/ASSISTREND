// chat_home_page.dart

import 'dart:convert';
import 'dart:async';
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
import '../../chat/application/providers/chat_open_state_provider.dart';
import '../../chat/application/providers/unread_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage({super.key});

  @override
  ConsumerState<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends ConsumerState<ChatHomePage> {
  NotificationsSocket? socket;
  int? currentUserId;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setup();
      if (!mounted) return;
      await _restoreUnreadFromCache();
      await _printAllUnreadMessages();
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    socket?.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    currentUserId = await Storage.getUserId();
    await _initializeSocket();
    if (!mounted) return;
    await _fetchAndCacheMissedMessages();
  }

  Future<void> _restoreUnreadFromCache() async {
    final data = await ChatCache.load();
    if (data == null || !mounted) return;

    final friends = data['friends'] as List<Friend>;
    final groups = data['groups'] as List<ChatGroup>;

    for (var friend in friends) {
      final messages = await MessageCache.loadFriendMessages(
        friend.id,
        currentUserId!,
      );
      final unreadCount = messages.where((m) => !m.read && !m.isMe).length;
      if (!mounted) return;
      if (unreadCount > 0) {
        ref
            .read(friendUnreadProvider.notifier)
            .setCount(friend.id, unreadCount);
      } else {
        ref.read(friendUnreadProvider.notifier).clear(friend.id);
      }
    }

    for (var group in groups) {
      final messages = await MessageCache.loadGroupMessages(
        group.id,
        currentUserId!,
      );
      final unreadCount = messages.where((m) => !m.read && !m.isMe).length;
      if (!mounted) return;
      if (unreadCount > 0) {
        ref.read(groupUnreadProvider.notifier).setCount(group.id, unreadCount);
      } else {
        ref.read(groupUnreadProvider.notifier).clear(group.id);
      }
    }
  }

  Future<void> _printAllUnreadMessages() async {
    debugPrint("🔎 Fetching all unread messages...");

    final data = await ChatCache.load();
    if (data == null || currentUserId == null) {
      debugPrint("⚠️ No cached chat data or user ID.");
      return;
    }

    final friends = data['friends'] as List<Friend>;
    final groups = data['groups'] as List<ChatGroup>;

    for (var friend in friends) {
      final messages = await MessageCache.loadFriendMessages(
        friend.id,
        currentUserId!,
      );
      final unreadMessages = messages.where((m) => !m.read && !m.isMe).toList();

      if (unreadMessages.isNotEmpty) {
        debugPrint(
          "📨 Unread messages from Friend ${friend.name} (ID: ${friend.id}):",
        );
        for (var m in unreadMessages) {
          debugPrint("  • [${m.timestamp}] ${m.content}");
        }
      }
    }

    for (var group in groups) {
      final messages = await MessageCache.loadGroupMessages(
        group.id,
        currentUserId!,
      );
      final unreadMessages = messages.where((m) => !m.read && !m.isMe).toList();

      if (unreadMessages.isNotEmpty) {
        debugPrint(
          "👥 Unread messages in Group ${group.name} (ID: ${group.id}):",
        );
        for (var m in unreadMessages) {
          debugPrint("  • [${m.timestamp}] ${m.content}");
        }
      }
    }

    debugPrint("✅ Finished printing unread messages.");
  }

  Future<void> _initializeSocket() async {
    final token = await TokenManager.ensureValidToken();
    if (token == null || currentUserId == null || !mounted) return;

    NotificationsSocket.initialize(token);
    socket = NotificationsSocket.instance!;
    _socketSubscription = socket!.stream.listen((event) async {
      // Early return if widget is disposed
      if (!mounted) return;

      print("📩 WebSocket message: $event");

      try {
        final decoded = jsonDecode(event);

        if (decoded['type'] == 'connection_established') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Connected to WebSocket")),
          );
          return;
        }

        if (decoded['type'] == 'new_one_to_one_message') {
          await _handleOneToOneMessage(decoded);
        }

        if (decoded['type'] == 'new_group_message') {
          await _handleGroupMessage(decoded);
        }
      } catch (e) {
        print("❌ Failed to decode WebSocket message: $e");
      }
    });
  }

  Future<void> _handleOneToOneMessage(Map<String, dynamic> decoded) async {
    if (!mounted) return;

    final payload = decoded['payload'];
    final senderId = payload['sender_id'];
    final receiverId =
        payload['receiver_id'] ?? currentUserId; // Fallback to current user
    final messageId = payload['id'];

    print(
      "🔍 Handling one-to-one message: sender=$senderId, receiver=$receiverId, currentUser=$currentUserId",
    );

    final message = ChatMessage.fromJson(payload, currentUserId!);

    // Determine which friend's chat this message belongs to
    int friendId;
    if (senderId == currentUserId) {
      // Current user sent the message, so the friend is the receiver
      friendId = receiverId;
    } else {
      // Current user received the message, so the friend is the sender
      friendId = senderId;
    }

    print("🎯 Message belongs to friend ID: $friendId");

    final existing = await MessageCache.loadFriendMessages(
      friendId,
      currentUserId!,
    );

    // Check mounted state after async operation
    if (!mounted) return;

    final alreadyExists = existing.any((m) => m.id == message.id);
    if (!alreadyExists) {
      existing.add(message);
      await MessageCache.saveFriendMessages(friendId, existing);

      // Check mounted state after another async operation
      if (!mounted) return;

      // Only increment unread count if:
      // 1. The message is not from the current user (message.isMe == false)
      // 2. The current user doesn't have this friend's chat open
      if (!message.isMe) {
        HapticFeedback.lightImpact();
        try {
          // Add extra safety check for mounted state
          if (!mounted) return;

          final openFriendId = ref.read(openFriendChatIdProvider);
          print(
            "🔍 Checking if friend $friendId chat is open. Current open: $openFriendId",
          );

          if (openFriendId != friendId) {
            // Double-check mounted state before updating
            if (!mounted) return;
            ref.read(friendUnreadProvider.notifier).increment(friendId);
            print("📈 Incremented unread count for friend $friendId");
          } else {
            print(
              "👀 Friend $friendId chat is open, not incrementing unread count",
            );
          }
        } catch (e) {
          print("❌ Error updating friend unread count: $e");
          return;
        }
      } else {
        print("📤 Message is from current user, not incrementing unread count");
      }
    } else {
      print("⚠️ Message already exists, skipping");
    }

    // Check mounted state before sending acknowledgment
    if (!mounted) return;

    socket?.send({
      "type": "acknowledge",
      "chat_type": "friend",
      "message_id": messageId,
    });
  }

  Future<void> _handleGroupMessage(Map<String, dynamic> decoded) async {
    if (!mounted) return;

    final payload = decoded['payload'];
    final groupId = payload['group_id'];
    final messageId = payload['id'];

    print(
      "🔍 Handling group message: group=$groupId, currentUser=$currentUserId",
    );

    final message = ChatMessage.fromJson(payload, currentUserId!);
    final existing = await MessageCache.loadGroupMessages(
      groupId,
      currentUserId!,
    );

    // Check mounted state after async operation
    if (!mounted) return;

    final alreadyExists = existing.any((m) => m.id == message.id);
    if (!alreadyExists) {
      existing.add(message);
      await MessageCache.saveGroupMessages(groupId, existing);

      // Check mounted state after another async operation
      if (!mounted) return;

      // Only increment unread count if:
      // 1. The message is not from the current user (message.isMe == false)
      // 2. The current user doesn't have this group chat open
      if (!message.isMe) {
        HapticFeedback.lightImpact();
        try {
          final openGroupId = ref.read(openGroupChatIdProvider);
          if (openGroupId != groupId) {
            ref.read(groupUnreadProvider.notifier).increment(groupId);
            print("📈 Incremented unread count for group $groupId");
          } else {
            print(
              "👀 Group $groupId chat is open, not incrementing unread count",
            );
          }
        } catch (e) {
          print("❌ Error updating group unread count: $e");
          return;
        }
      } else {
        print("📤 Message is from current user, not incrementing unread count");
      }
    } else {
      print("⚠️ Message already exists, skipping");
    }

    // Check mounted state before sending acknowledgment
    if (!mounted) return;

    socket?.send({
      "type": "acknowledge",
      "chat_type": "group",
      "message_id": messageId,
    });
  }

  Future<void> _fetchAndCacheMissedMessages() async {
    final token = await TokenManager.ensureValidToken();
    if (token == null || currentUserId == null || !mounted) return;

    final uri = Uri.parse('http://10.0.2.2:8002/api/missed-messages/');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 && mounted) {
      final data = jsonDecode(response.body);
      final List oneToOneMessages = data['one_to_one_messages'];
      final List groupMessages = data['group_messages'];

      for (var msg in oneToOneMessages) {
        final friendId = msg['sender_id'];
        final oldMessages = await MessageCache.loadFriendMessages(
          friendId,
          currentUserId!,
        );

        if (!mounted) return;

        final exists = oldMessages.any((m) => m.id == msg['id']);
        if (!exists) {
          oldMessages.add(
            ChatMessage(
              id: msg['id'],
              senderId: friendId,
              receiverId: currentUserId!,
              content: msg['message'] ?? '',
              timestamp: DateTime.parse(msg['timestamp']),
              isMe: false,
              imageUrl: msg['image'],
              read: false,
            ),
          );
          await MessageCache.saveFriendMessages(friendId, oldMessages);

          if (!mounted) return;
          final openFriendId = ref.read(openFriendChatIdProvider);
          if (openFriendId != friendId) {
            ref.read(friendUnreadProvider.notifier).increment(friendId);
          }
        }
      }

      for (var msg in groupMessages) {
        final groupId = msg['group_id'];
        final oldMessages = await MessageCache.loadGroupMessages(
          groupId,
          currentUserId!,
        );

        if (!mounted) return;

        final exists = oldMessages.any((m) => m.id == msg['id']);
        if (!exists) {
          oldMessages.add(
            ChatMessage(
              id: msg['id'],
              senderId: msg['sender_id'],
              groupId: groupId,
              content: msg['message'] ?? '',
              timestamp: DateTime.parse(msg['timestamp']),
              isMe: false,
              imageUrl: msg['image'],
              read: false,
            ),
          );
          await MessageCache.saveGroupMessages(groupId, oldMessages);

          if (!mounted) return;
          final openGroupId = ref.read(openGroupChatIdProvider);
          if (openGroupId != groupId) {
            ref.read(groupUnreadProvider.notifier).increment(groupId);
          }
        }
      }
    } else {
      print("❌ Failed to fetch missed messages: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatProvider);
    final friendUnread = ref.watch(friendUnreadProvider);
    final groupUnread = ref.watch(groupUnreadProvider);

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
              await _restoreUnreadFromCache();
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
                          if (friendUnread[friend.id] != null)
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  friendUnread[friend.id].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        friend.name.isNotEmpty ? friend.name : 'Unnamed',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        ref
                            .read(friendUnreadProvider.notifier)
                            .clear(friend.id);
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
                          if (groupUnread[group.id] != null)
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  groupUnread[group.id].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        ref.read(groupUnreadProvider.notifier).clear(group.id);
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

// friend_chat_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/chat/utils/message_cache.dart';
import 'package:assistrend/features/chat/domain/models/chat_message.dart';
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import '../../application/providers/chat_open_state_provider.dart';

class FriendChatPage extends ConsumerStatefulWidget {
  final int friendId;
  final String friendName;

  const FriendChatPage({
    super.key,
    required this.friendId,
    required this.friendName,
  });

  @override
  ConsumerState<FriendChatPage> createState() => _FriendChatPageState();
}

class _FriendChatPageState extends ConsumerState<FriendChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  NotificationsSocket? socket;

  late final int currentUserId;

  @override
  void initState() {
    super.initState();

    // Set current open friend chat ID
    Future.microtask(() {
      ref.read(openFriendChatIdProvider.notifier).state = widget.friendId;
    });

    currentUserId = ref.read(authProvider).userId ?? 0;
    _loadMessages();
    _initSocket();
  }

  @override
  void dispose() {
    // Clear open friend chat ID
    ref.read(openFriendChatIdProvider.notifier).state = null;
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final loaded = await MessageCache.loadFriendMessages(
      widget.friendId,
      currentUserId,
    );

    // Mark unread messages as read
    bool updated = false;
    for (final msg in loaded) {
      if (!msg.read && !msg.isMe) {
        msg.read = true;
        updated = true;
      }
    }
    if (updated) {
      await MessageCache.saveFriendMessages(widget.friendId, loaded);
    }

    setState(() => _messages.addAll(loaded));
  }

  void _initSocket() {
    socket = NotificationsSocket.instance;

    if (socket == null) {
      debugPrint("❌ WebSocket not initialized.");
      return;
    }

    socket!.stream.listen((event) {
      try {
        final data = jsonDecode(event);

        if (data['type'] == 'new_one_to_one_message' &&
            data['payload']['sender_id'] == widget.friendId) {
          final newMessage = ChatMessage.fromJson(
            data['payload'],
            currentUserId,
          );
          newMessage.read = true;
          setState(() => _messages.add(newMessage));
          MessageCache.saveFriendMessages(widget.friendId, _messages);
        }
      } catch (e) {
        debugPrint("❌ Error parsing incoming message: $e");
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    final message = ChatMessage(
      id: now.millisecondsSinceEpoch,
      senderId: currentUserId,
      receiverId: widget.friendId,
      content: text,
      timestamp: now,
      isMe: true,
      imageUrl: null,
      read: true,
    );

    final payload = {
      "type": "chat_message",
      "chat_type": "friend",
      "target_id": widget.friendId,
      "message": text,
      "image": null,
    };

    socket?.send(payload);
    setState(() => _messages.add(message));
    MessageCache.saveFriendMessages(widget.friendId, _messages);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.friendName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[_messages.length - 1 - index];
                return Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? const Color.fromARGB(255, 17, 26, 34)
                          : const Color.fromARGB(255, 2, 2, 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Image.network(
                              'http://10.0.2.2:8002${msg.imageUrl}',
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text('📷 Failed to load image'),
                            ),
                          ),
                        Text(msg.content),
                        const SizedBox(height: 4),
                        Text(
                          msg.timestamp.toLocal().toString().split('.')[0],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 210, 61, 61),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller)),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

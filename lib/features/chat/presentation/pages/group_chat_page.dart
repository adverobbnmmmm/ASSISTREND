// === group_chat_page.dart ===

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/chat/utils/message_cache.dart';
import 'package:assistrend/features/chat/domain/models/chat_message.dart';
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import '../../application/providers/chat_open_state_provider.dart'; // <-- ✅ Add this

class GroupChatPage extends ConsumerStatefulWidget {
  final int groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends ConsumerState<GroupChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  NotificationsSocket? socket;
  late final int currentUserId;

  @override
  void initState() {
    super.initState();

    // ✅ Store the current open group chat ID in global Riverpod state
    Future.microtask(() {
      ref.read(openGroupChatIdProvider.notifier).state = widget.groupId;
    });

    currentUserId = ref.read(authProvider).userId ?? 0;
    _loadMessages();
    _initSocket();
  }

  @override
  void dispose() {
    // ✅ Clear the currently open group chat ID on exit
    ref.read(openGroupChatIdProvider.notifier).state = null;

    super.dispose();
  }

  Future<void> _loadMessages() async {
    final loaded = await MessageCache.loadGroupMessages(
      widget.groupId,
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
      await MessageCache.saveGroupMessages(widget.groupId, loaded);
    }

    setState(() => _messages.addAll(loaded));
  }

  void _initSocket() {
    socket = NotificationsSocket.instance;

    if (socket == null) {
      debugPrint("No WebSocket instance found");
      return;
    }

    socket!.stream.listen((event) {
      try {
        final data = jsonDecode(event);

        if (data['type'] == 'new_group_message' &&
            data['payload']['group_id'] == widget.groupId) {
          final message = ChatMessage.fromJson(data['payload'], currentUserId);
          message.read = true;
          setState(() => _messages.add(message));
          MessageCache.saveGroupMessages(widget.groupId, _messages);
        }
      } catch (_) {}
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    final message = ChatMessage(
      id: now.millisecondsSinceEpoch,
      senderId: currentUserId,
      groupId: widget.groupId,
      content: text,
      timestamp: now,
      isMe: true,
      imageUrl: null,
      read: true,
    );

    final payload = {
      "type": "chat_message",
      "chat_type": "group",
      "target_id": widget.groupId,
      "message": text,
      "image": null,
    };

    socket?.send(payload);

    setState(() => _messages.add(message));
    MessageCache.saveGroupMessages(widget.groupId, _messages);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
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
                        if (msg.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Image.network(
                              'http://10.0.2.2:8002${msg.imageUrl}',
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

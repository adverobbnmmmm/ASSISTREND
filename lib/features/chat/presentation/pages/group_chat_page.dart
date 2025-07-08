// group_chat_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:assistrend/features/chat/utils/message_cache.dart';
import 'package:assistrend/features/chat/domain/models/chat_message.dart';
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';

class GroupChatPage extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  NotificationsSocket? socket;

  int currentUserId = 0; // TODO: Replace this with actual logged-in user ID

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initSocket();
  }

  Future<void> _loadMessages() async {
    final loaded = await MessageCache.loadGroupMessages(widget.groupId, currentUserId);
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
            data['group_id'] == widget.groupId) {
          final message = ChatMessage.fromJson(data, currentUserId);
          setState(() {
            _messages.add(message);
          });
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
    );

    final payload = {
      "type": "send_group_message",
      "group_id": widget.groupId,
      "content": text,
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
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.content),
                        const SizedBox(height: 4),
                        Text(
                          msg.timestamp.toLocal().toString().split('.')[0],
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
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

// lib/features/chat/presentation/pages/friend_chat_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:assistrend/features/chat/utils/message_cache.dart'; // Uses ChatMessage
import 'package:assistrend/features/chat/domain/models/chat_message.dart'; // Correct model
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';

class FriendChatPage extends StatefulWidget {
  final int friendId;
  final String friendName;

  const FriendChatPage({
    super.key,
    required this.friendId,
    required this.friendName,
  });

  @override
  State<FriendChatPage> createState() => _FriendChatPageState();
}

class _FriendChatPageState extends State<FriendChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  NotificationsSocket? socket;

  int currentUserId = 0; // Replace this with actual user ID from auth state

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initSocket();
  }

  /// Loads cached messages from SharedPreferences
  Future<void> _loadMessages() async {
    final loaded = await MessageCache.loadFriendMessages(widget.friendId, currentUserId);
    setState(() {
      _messages.addAll(loaded);
    });
  }

  /// Initializes the socket and listens to incoming messages
  void _initSocket() {
    socket = NotificationsSocket.instance;

    if (socket == null) {
      debugPrint("❌ No WebSocket instance found. Make sure it's initialized in ChatHomePage.");
      return;
    }

    socket!.stream.listen((event) {
      try {
        final data = jsonDecode(event);

        if (data['type'] == 'new_one_to_one_message' &&
            data['sender_id'] == widget.friendId) {
          final newMessage = ChatMessage.fromJson(data, currentUserId);

          setState(() {
            _messages.add(newMessage);
          });

          MessageCache.saveFriendMessages(widget.friendId, _messages);
        }
      } catch (e) {
        debugPrint("❌ Failed to parse message: $e");
      }
    });
  }

  /// Sends a message through the WebSocket and adds it to the UI
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    final myMessage = ChatMessage(
      id: now.millisecondsSinceEpoch,
      senderId: currentUserId,
      receiverId: widget.friendId,
      content: text,
      timestamp: now,
      isMe: true,
    );

    final payload = {
      "type": "send_one_to_one_message",
      "receiver_id": widget.friendId,
      "content": text,
    };

    socket?.send(payload);

    setState(() {
      _messages.add(myMessage);
    });

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
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Colors.blue[100] : Colors.grey[300],
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

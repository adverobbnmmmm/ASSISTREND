import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:assistrend/features/chat/utils/message_cache.dart';
import 'package:assistrend/features/chat/domain/models/chat_message.dart';
import 'package:assistrend/features/chat/application/services/notifications_socket.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:assistrend/shared/services/auth_helper.dart';

import '../../application/providers/chat_open_state_provider.dart';

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
  List<ChatMessage> _messages = [];
  NotificationsSocket? socket;

  late final int currentUserId;
  String? authToken;

  @override
  void initState() {
    super.initState();

    // ✅ Store currently open group chat
    Future.microtask(() {
      ref.read(openGroupChatIdProvider.notifier).state = widget.groupId;
    });

    final authState = ref.read(authProvider);
    currentUserId = authState.userId ?? 0;

    // ✅ Ensure valid token, then load messages
    TokenManager.ensureValidToken().then((token) {
      authToken = token;
      _loadMessages();
    });

    _initSocket();
  }

  @override
  void dispose() {
    // ✅ Clear open chat ID
    ref.read(openGroupChatIdProvider.notifier).state = null;
    super.dispose();
  }

  /// ✅ Improved message loading with better deduplication
  Future<void> _loadMessages() async {
    final cached = await MessageCache.loadGroupMessages(
      widget.groupId,
      currentUserId,
    );

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8002/api/messages/group-history/?group_id=${widget.groupId}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<ChatMessage> backendMessages = (decoded['messages'] as List)
            .map((json) => ChatMessage.fromJson(json, currentUserId))
            .toList();

        // ✅ Enhanced deduplication logic
        final mergedMessages = _mergeMessages(cached, backendMessages);

        // Mark unread messages as read
        bool updated = false;
        for (final msg in mergedMessages) {
          if (!msg.read && !msg.isMe) {
            msg.read = true;
            updated = true;
          }
        }

        // Save to cache (always save backend data to keep it fresh)
        await MessageCache.saveGroupMessages(widget.groupId, mergedMessages);

        setState(() => _messages = mergedMessages);
      } else {
        debugPrint("❌ Backend fetch failed: ${response.body}");
        setState(() => _messages = cached);
      }
    } catch (e) {
      debugPrint("❌ Error fetching group messages: $e");
      setState(() => _messages = cached);
    }
  }

  /// ✅ Enhanced message merging with multiple deduplication strategies
  List<ChatMessage> _mergeMessages(
    List<ChatMessage> cached,
    List<ChatMessage> backend,
  ) {
    // Use backend messages as the source of truth
    final Map<int, ChatMessage> backendMap = {
      for (final msg in backend) msg.id: msg,
    };

    // Find cached messages that might not be in backend yet (pending messages)
    final List<ChatMessage> pendingMessages = [];

    for (final cachedMsg in cached) {
      bool foundInBackend = false;

      // Check if this cached message exists in backend (by ID)
      if (backendMap.containsKey(cachedMsg.id)) {
        foundInBackend = true;
      } else {
        // Check for potential duplicates by content, timestamp, and sender
        // This handles cases where local message has temp ID but backend has real ID
        foundInBackend = backend.any(
          (backendMsg) => _messagesAreSimilar(cachedMsg, backendMsg),
        );
      }

      if (!foundInBackend) {
        // This is likely a pending message that hasn't reached backend yet
        pendingMessages.add(cachedMsg);
      }
    }

    // Combine backend messages with pending messages
    final allMessages = [...backend, ...pendingMessages];

    // Sort by timestamp
    allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return allMessages;
  }

  /// ✅ Helper method to check if two messages are likely the same
  bool _messagesAreSimilar(ChatMessage msg1, ChatMessage msg2) {
    // Check if messages are similar enough to be considered duplicates
    final timeDiff =
        (msg1.timestamp.millisecondsSinceEpoch -
                msg2.timestamp.millisecondsSinceEpoch)
            .abs();

    return msg1.content == msg2.content &&
        msg1.senderId == msg2.senderId &&
        msg1.groupId == msg2.groupId &&
        timeDiff < 5000; // Within 5 seconds
  }

  void _initSocket() {
    socket = NotificationsSocket.instance;

    if (socket == null) {
      debugPrint("❌ No WebSocket instance found");
      return;
    }

    socket!.stream.listen((event) {
      try {
        final data = jsonDecode(event);

        if (data['type'] == 'new_group_message' &&
            data['payload']['group_id'] == widget.groupId) {
          final message = ChatMessage.fromJson(data['payload'], currentUserId);
          message.read = true;

          // ✅ Enhanced duplicate checking
          if (_isDuplicateMessage(message)) {
            debugPrint("🔄 Duplicate group message detected, skipping");
            return;
          }

          setState(() => _messages.add(message));
          MessageCache.saveGroupMessages(widget.groupId, _messages);
        }
      } catch (e) {
        debugPrint("❌ Error handling socket data: $e");
      }
    });
  }

  /// ✅ Enhanced duplicate detection for incoming messages
  bool _isDuplicateMessage(ChatMessage newMessage) {
    return _messages.any(
      (existingMsg) =>
          existingMsg.id == newMessage.id ||
          _messagesAreSimilar(existingMsg, newMessage),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    // ✅ Use negative timestamp as temporary ID to avoid conflicts
    final tempId = -now.millisecondsSinceEpoch;

    final message = ChatMessage(
      id: tempId, // Temporary negative ID
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

    // ✅ Check for duplicates before adding
    if (!_isDuplicateMessage(message)) {
      setState(() => _messages.add(message));
      MessageCache.saveGroupMessages(widget.groupId, _messages);
    }

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
                        if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Image.network(
                              'http://10.0.2.2:8002${msg.imageUrl}',
                              errorBuilder: (_, __, ___) =>
                                  const Text('📷 Image failed to load'),
                            ),
                          ),
                        Text(msg.content),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.timestamp.toLocal().toString().split('.')[0],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color.fromARGB(255, 210, 61, 61),
                              ),
                            ),
                            // ✅ Show pending indicator for temp messages
                            if (msg.id < 0) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.schedule,
                                size: 12,
                                color: Colors.orange,
                              ),
                            ],
                          ],
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

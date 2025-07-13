import 'dart:convert';
import 'package:assistrend/shared/services/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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
  List<ChatMessage> _messages = [];
  NotificationsSocket? socket;

  late final int currentUserId;
  String? authToken;

  @override
  void initState() {
    super.initState();

    // Mark current chat as open
    Future.microtask(() {
      ref.read(openFriendChatIdProvider.notifier).state = widget.friendId;
    });

    final authState = ref.read(authProvider);
    currentUserId = authState.userId ?? 0;
    TokenManager.ensureValidToken().then((token) {
      authToken = token;
      _loadMessages();
    });
    _initSocket();
  }

  @override
  void dispose() {
    ref.read(openFriendChatIdProvider.notifier).state = null;
    super.dispose();
  }

  /// ✅ Improved message loading with better deduplication
  Future<void> _loadMessages() async {
    final cached = await MessageCache.loadFriendMessages(
      widget.friendId,
      currentUserId,
    );

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8002/api/messages/history/?sender_id=$currentUserId&receiver_id=${widget.friendId}',
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
        await MessageCache.saveFriendMessages(widget.friendId, mergedMessages);

        setState(() => _messages = mergedMessages);
      } else {
        debugPrint("❌ Backend load failed: ${response.body}");
        setState(() => _messages = cached);
      }
    } catch (e) {
      debugPrint("❌ Error loading messages: $e");
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
        msg1.receiverId == msg2.receiverId &&
        timeDiff < 5000; // Within 5 seconds
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

        if (data['type'] == 'new_one_to_one_message') {
          final newMessage = ChatMessage.fromJson(
            data['payload'],
            currentUserId,
          );
          newMessage.read = true;

          // ✅ Handle both incoming and outgoing messages
          if (data['payload']['sender_id'] == widget.friendId) {
            // Incoming message from friend
            if (_isDuplicateMessage(newMessage)) {
              debugPrint("🔄 Duplicate incoming message detected, skipping");
              return;
            }
            setState(() => _messages.add(newMessage));
          } else if (data['payload']['sender_id'] == currentUserId) {
            // Our own message coming back - replace temporary message
            _replaceTemporaryMessage(newMessage);
          }

          MessageCache.saveFriendMessages(widget.friendId, _messages);
        }
      } catch (e) {
        debugPrint("❌ Error parsing socket message: $e");
      }
    });
  }

  /// ✅ Replace temporary message with backend-confirmed message
  void _replaceTemporaryMessage(ChatMessage confirmedMessage) {
    final tempMessageIndex = _messages.indexWhere(
      (msg) => msg.id < 0 && _messagesAreSimilar(msg, confirmedMessage),
    );

    if (tempMessageIndex != -1) {
      setState(() {
        _messages[tempMessageIndex] = confirmedMessage;
      });
      debugPrint("✅ Replaced temporary message with confirmed message");
    } else {
      // If no temp message found, just add it (shouldn't happen normally)
      if (!_isDuplicateMessage(confirmedMessage)) {
        setState(() => _messages.add(confirmedMessage));
      }
    }
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

    // ✅ Check for duplicates before adding
    if (!_isDuplicateMessage(message)) {
      setState(() => _messages.add(message));
      MessageCache.saveFriendMessages(widget.friendId, _messages);
    }

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

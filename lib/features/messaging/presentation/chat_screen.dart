import 'dart:async';
import 'package:flutter/material.dart';

import '../../../shared/utils/storage.dart';
import '../models/chat_models.dart';
import '../services/chat_socket.dart';
import '../services/messaging_api.dart';

/// Live chat screen for a single conversation (direct or group).
class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatSocket _socket = ChatSocket();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  StreamSubscription? _sub;

  List<ChatMessage> _messages = [];
  String? _userId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final userId = await Storage.getUserId();
      final token = await Storage.getToken();
      if (userId == null || token == null) {
        setState(() {
          _error = 'Not authenticated';
          _loading = false;
        });
        return;
      }
      _userId = userId;

      // 1. Load history over REST
      final history = await MessagingApi.getMessages(widget.conversation.id);

      // 2. Open the live socket (authenticated with the JWT) and listen
      _socket.connect(widget.conversation.id, token);
      _sub = _socket.messages.listen(_onIncoming, onError: (_) {});

      setState(() {
        _messages = history;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onIncoming(ChatMessage msg) {
    // Avoid duplicates if the same message id already exists.
    if (_messages.any((m) => m.id == msg.id)) return;
    setState(() => _messages = [..._messages, msg]);
    _scrollToBottom();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _socket.send(text);
    _input.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _socket.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101012),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: c.isGroup ? Colors.deepPurple : Colors.blueGrey,
              backgroundImage:
                  c.avatar.isNotEmpty ? NetworkImage(c.avatar) : null,
              child: c.avatar.isEmpty
                  ? Icon(c.isGroup ? Icons.groups : Icons.person,
                      color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.title,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis),
                  if (c.isGroup)
                    Text('${c.members.length} members',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text('Say hi 👋',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final isMine = m.senderId == _userId;
        return _MessageBubble(
          message: m,
          isMine: isMine,
          showSender: widget.conversation.isGroup && !isMine,
        );
      },
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: const Color(0xFF101012),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                style: const TextStyle(color: Colors.white),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: const Color(0xFF1E1E20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showSender;
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showSender,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue : const Color(0xFF1E1E20),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showSender)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(message.senderName,
                    style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            Text(message.text,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 3),
            Text(time,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/storage.dart';
import '../models/chat_models.dart';
import '../services/messaging_api.dart';

/// Pick a user to start a 1:1 chat with.
class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<ChatUser> _users = [];
  String? _userId;
  bool _loading = true;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String q = ''}) async {
    final userId = _userId ?? await Storage.getUserId();
    _userId = userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final users = await MessagingApi.getUsers(q: q);
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(q: value));
  }

  Future<void> _startChat(ChatUser user) async {
    if (_userId == null || _starting) return;
    setState(() => _starting = true);
    try {
      final convo = await MessagingApi.createDirect(user.id);
      if (mounted) {
        // Replace this screen with the chat.
        context.pushReplacementNamed('chat', extra: convo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
        setState(() => _starting = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101012),
        foregroundColor: Colors.white,
        title: const Text('New chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1E1E20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_starting) const LinearProgressIndicator(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue))
                : _users.isEmpty
                    ? Center(
                        child: Text('No users found',
                            style: TextStyle(color: Colors.grey.shade500)))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, i) {
                          final u = _users[i];
                          return ListTile(
                            onTap: () => _startChat(u),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              backgroundImage: u.profileImageUrl.isNotEmpty
                                  ? NetworkImage(u.profileImageUrl)
                                  : null,
                              child: u.profileImageUrl.isEmpty
                                  ? Text(
                                      u.username.isNotEmpty
                                          ? u.username[0].toUpperCase()
                                          : '?',
                                      style:
                                          const TextStyle(color: Colors.white))
                                  : null,
                            ),
                            title: Text(u.username,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(u.email,
                                style:
                                    TextStyle(color: Colors.grey.shade600)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

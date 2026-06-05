import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/storage.dart';
import '../models/chat_models.dart';
import '../services/messaging_api.dart';

/// Create a group: enter a name and pick members.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _name = TextEditingController();
  final Set<String> _selected = {};
  List<ChatUser> _users = [];
  String? _userId;
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = await Storage.getUserId();
    _userId = userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final users = await MessagingApi.getUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a group name')),
      );
      return;
    }
    if (_userId == null || _creating) return;
    setState(() => _creating = true);
    try {
      final convo = await MessagingApi.createGroup(
          name, _selected.toList());
      if (mounted) {
        context.pushReplacementNamed('chat', extra: convo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
        setState(() => _creating = false);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101012),
        foregroundColor: Colors.white,
        title: const Text('New group'),
        actions: [
          TextButton(
            onPressed: _creating ? null : _create,
            child: const Text('Create',
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Group name',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.groups, color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF1E1E20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_creating) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add members (${_selected.length} selected)',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      final u = _users[i];
                      final checked = _selected.contains(u.id);
                      return CheckboxListTile(
                        value: checked,
                        activeColor: Colors.blue,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selected.add(u.id);
                            } else {
                              _selected.remove(u.id);
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          backgroundImage: u.profileImageUrl.isNotEmpty
                              ? NetworkImage(u.profileImageUrl)
                              : null,
                          child: u.profileImageUrl.isEmpty
                              ? Text(
                                  u.username.isNotEmpty
                                      ? u.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white))
                              : null,
                        ),
                        title: Text(u.username,
                            style: const TextStyle(color: Colors.white)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

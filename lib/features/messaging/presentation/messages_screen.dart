import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/chat_models.dart';
import '../providers/messaging_providers.dart';

/// Conversation list with two tabs: direct Chats and Groups.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(conversationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101012),
          foregroundColor: Colors.white,
          title: const Text('Messages'),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: 'Chats'), Tab(text: 'Groups')],
          ),
        ),
        floatingActionButton: _buildFab(context),
        body: convosAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: Colors.blue)),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(conversationsProvider),
          ),
          data: (convos) {
            final direct = convos.where((c) => !c.isGroup).toList();
            final groups = convos.where((c) => c.isGroup).toList();
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(conversationsProvider),
              child: TabBarView(
                children: [
                  _ConversationList(items: direct, emptyLabel: 'No chats yet'),
                  _ConversationList(items: groups, emptyLabel: 'No groups yet'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
      color: const Color(0xFF1A1A1A),
      onSelected: (value) {
        if (value == 'chat') {
          context.pushNamed('newChat');
        } else if (value == 'group') {
          context.pushNamed('createGroup');
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'chat',
          child: Text('New chat', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'group',
          child: Text('New group', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _ConversationList extends StatelessWidget {
  final List<Conversation> items;
  final String emptyLabel;
  const _ConversationList({required this.items, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.forum_outlined, color: Colors.grey.shade700, size: 56),
          const SizedBox(height: 12),
          Center(
            child: Text(emptyLabel,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ),
        ],
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade900, height: 1),
      itemBuilder: (context, i) {
        final c = items[i];
        final preview = c.lastMessage?.text ?? 'Tap to start chatting';
        return ListTile(
          onTap: () => context.pushNamed('chat', extra: c),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: c.isGroup ? Colors.deepPurple : Colors.blueGrey,
            backgroundImage: c.avatar.isNotEmpty ? NetworkImage(c.avatar) : null,
            child: c.avatar.isEmpty
                ? Icon(c.isGroup ? Icons.groups : Icons.person,
                    color: Colors.white)
                : null,
          ),
          title: Text(c.title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

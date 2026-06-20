import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/messaging/services/messaging_api.dart';
import 'package:assistrend/features/messaging/presentation/chat_screen.dart';

// ---------------------------------------------------------------------------
// Arena page — interest-based group chats
// ---------------------------------------------------------------------------

class ArenaPage extends ConsumerStatefulWidget {
  const ArenaPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ArenaPage> createState() => _ArenaPageState();
}

class _ArenaPageState extends ConsumerState<ArenaPage> {
  List<ArenaGroupInfo> _groups = [];
  bool _loading = true;
  String? _error;
  final Set<int> _joining = {};

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await MessagingApi.getArenaGroups();
      if (mounted) setState(() { _groups = groups; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _joinAndOpen(ArenaGroupInfo group) async {
    setState(() => _joining.add(group.interestId));
    try {
      final conversation = await MessagingApi.joinArenaGroup(group.interestId);
      if (!mounted) return;
      // Refresh list so isMember updates
      _loadGroups();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not join group: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joining.remove(group.interestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1217),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _loadGroups,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white54, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 28,
                height: 1.2,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: 'Your '),
                TextSpan(
                  text: 'Arena',
                  style: TextStyle(color: Color(0xFF1D5EFF)),
                ),
                TextSpan(text: ' rooms'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Group chats for every interest you follow.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.07)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1D5EFF), strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 48, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Could not load rooms',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5EFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                onPressed: _loadGroups,
                child: const Text('Try again',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D5EFF).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.interests_outlined,
                    size: 48, color: Color(0xFF1D5EFF)),
              ),
              const SizedBox(height: 20),
              const Text(
                'No interest groups yet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Add interests to your profile to\nsee relevant Arena rooms here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1D5EFF),
      backgroundColor: const Color(0xFF1A1F28),
      onRefresh: _loadGroups,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _ArenaGroupCard(
          group: _groups[index],
          isJoining: _joining.contains(_groups[index].interestId),
          onTap: () => _joinAndOpen(_groups[index]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group card widget
// ---------------------------------------------------------------------------

class _ArenaGroupCard extends StatelessWidget {
  final ArenaGroupInfo group;
  final bool isJoining;
  final VoidCallback onTap;

  const _ArenaGroupCard({
    required this.group,
    required this.isJoining,
    required this.onTap,
  });

  // Simple deterministic color per interest for the avatar background
  Color _avatarColor() {
    const palette = [
      Color(0xFF1D5EFF),
      Color(0xFF7B2FBE),
      Color(0xFF0E9E6E),
      Color(0xFFD4430F),
      Color(0xFF0F7DA1),
      Color(0xFFB5870E),
    ];
    return palette[group.interestId % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    return GestureDetector(
      onTap: isJoining ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: group.isMember
                ? color.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + members
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${group.interestName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 13, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                      if (group.isMember) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Joined',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action button
            if (isJoining)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: color),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: group.isMember ? color.withOpacity(0.15) : color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  group.isMember ? 'Enter' : 'Join',
                  style: TextStyle(
                    color: group.isMember ? color : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

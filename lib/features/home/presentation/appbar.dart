import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assistrend/core/network/api_service.dart';
import 'package:assistrend/shared/utils/storage.dart';

class AppBarwidget extends ConsumerStatefulWidget {
  final Widget? logoutButton;
  const AppBarwidget({Key? key, this.logoutButton}) : super(key: key);

  @override
  ConsumerState<AppBarwidget> createState() => _AppBarwidgetState();
}

class _AppBarwidgetState extends ConsumerState<AppBarwidget> {
  String? userName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  /// Pull the real display name from the profile endpoint
  /// (profile/me returns name / display_name / username).
  Future<void> _loadUserName() async {
    setState(() => isLoading = true);
    try {
      final userId = await Storage.getUserId();
      if (userId != null) {
        final response = await ApiService.getUserProfile(userId);
        final data = (response is Map && response['data'] != null)
            ? response['data']
            : response;
        final name = (data['name'] ??
                data['display_name'] ??
                data['username'] ??
                '')
            .toString();
        if (mounted) {
          setState(() {
            userName = name.isNotEmpty ? name : 'User';
            isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // fall through to default below
    }
    if (mounted) {
      setState(() {
        userName = 'User';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff181a1c),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Welcome ${userName ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => context.pushNamed('messages'),
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                tooltip: 'Messages',
              ),
              if (widget.logoutButton != null) widget.logoutButton!,
            ],
          ),
        ],
      ),
    );
  }
}

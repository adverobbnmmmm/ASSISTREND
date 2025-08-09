import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _getUserNameFromPrefs();
  }

  Future<void> _getUserNameFromPrefs() async {
    setState(() { isLoading = true; });
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    setState(() {
      userName = name.isNotEmpty ? name : 'User';
      isLoading = false;
    });
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
              ? const CircularProgressIndicator()
              : Text(
                  'Welcome ${userName ?? 'Jen'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          if (widget.logoutButton != null) widget.logoutButton!,
        ],
      ),
    );
  }
}
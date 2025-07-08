// lib/features/chat/utils/chat_cache.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../chat/domain/models/chat_models.dart';

class ChatCache {
  static const _key = 'cached_chats';

  static Future<void> save({
    required List<Friend> friends,
    required List<ChatGroup> groups,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode({
      'friends': friends.map((f) => f.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
    });

    await prefs.setString(_key, jsonString);
  }

  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    final friendsJson = decoded['friends'] as List<dynamic>;
    final groupsJson = decoded['groups'] as List<dynamic>;

    return {
      'friends': friendsJson.map((e) => Friend.fromJson(e)).toList(),
      'groups': groupsJson.map((e) => ChatGroup.fromJson(e)).toList(),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

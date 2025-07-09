import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/chat_message.dart';

/// A utility class for saving and loading cached chat messages locally.
class MessageCache {
  // ========================
  // 🔵 FRIEND MESSAGE SUPPORT
  // ========================

  /// Save messages for a specific friend chat
  static Future<void> saveFriendMessages(int friendId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'friend_messages_$friendId';
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  /// Load saved friend messages
  static Future<List<ChatMessage>> loadFriendMessages(int friendId, int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'friend_messages_$friendId';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => ChatMessage.fromJson(e, currentUserId)).toList();
  }

  /// Clear cache for a specific friend chat
  static Future<void> clearFriendChat(int friendId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('friend_messages_$friendId');
  }

  // ========================
  // 🟢 GROUP MESSAGE SUPPORT
  // ========================

  /// Save messages for a specific group chat
  static Future<void> saveGroupMessages(int groupId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'group_messages_$groupId';
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  /// Load saved group messages
  static Future<List<ChatMessage>> loadGroupMessages(int groupId, int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'group_messages_$groupId';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => ChatMessage.fromJson(e, currentUserId)).toList();
  }

  /// Clear cache for a specific group chat
  static Future<void> clearGroupChat(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('group_messages_$groupId');
  }
}

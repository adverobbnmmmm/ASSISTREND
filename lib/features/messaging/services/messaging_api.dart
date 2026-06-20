import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:assistrend/config/app_config.dart';
import '../../../shared/utils/storage.dart';
import '../models/chat_models.dart';

/// REST calls for messaging. Every request carries the JWT access token; the
/// backend derives the acting user from it (it no longer trusts a userId).
class MessagingApi {
  static const String _base = AppConfig.messagingBaseUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await Storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Conversation>> getConversations() async {
    final res = await http.get(
      Uri.parse('${_base}conversations/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['conversations'] as List<dynamic>)
          .map((c) => Conversation.fromJson(c))
          .toList();
    }
    throw Exception('Failed to load conversations (${res.statusCode})');
  }

  static Future<Conversation> createDirect(String otherUserId) async {
    final res = await http.post(
      Uri.parse('${_base}conversations/direct/'),
      headers: await _headers(),
      body: jsonEncode({'otherUserId': otherUserId}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(res.body)['conversation']);
    }
    throw Exception('Failed to start chat (${res.statusCode})');
  }

  static Future<Conversation> createGroup(
      String name, List<String> memberIds) async {
    final res = await http.post(
      Uri.parse('${_base}conversations/group/'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'memberIds': memberIds}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(res.body)['conversation']);
    }
    throw Exception('Failed to create group (${res.statusCode})');
  }

  static Future<List<ChatMessage>> getMessages(int conversationId) async {
    final res = await http.get(
      Uri.parse('${_base}conversations/$conversationId/messages/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['messages'] as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m))
          .toList();
    }
    throw Exception('Failed to load messages (${res.statusCode})');
  }

  /// REST fallback for sending (the live path is the WebSocket).
  static Future<void> sendMessage(int conversationId, String text) async {
    await http.post(
      Uri.parse('${_base}conversations/$conversationId/messages/send/'),
      headers: await _headers(),
      body: jsonEncode({'text': text}),
    );
  }

  static Future<List<ChatUser>> getUsers({String q = ''}) async {
    final res = await http.get(
      Uri.parse('${_base}users/?q=$q'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['users'] as List<dynamic>)
          .map((u) => ChatUser.fromJson(u))
          .toList();
    }
    throw Exception('Failed to load users (${res.statusCode})');
  }

  /// Returns arena groups matched to the current user's interests.
  static Future<List<ArenaGroupInfo>> getArenaGroups() async {
    final res = await http.get(
      Uri.parse('${_base}arena/groups/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['groups'] as List<dynamic>)
          .map((g) => ArenaGroupInfo.fromJson(g))
          .toList();
    }
    throw Exception('Failed to load arena groups (${res.statusCode})');
  }

  /// Joins the arena group for [interestId] and returns the conversation.
  static Future<Conversation> joinArenaGroup(int interestId) async {
    final res = await http.post(
      Uri.parse('${_base}arena/groups/$interestId/join/'),
      headers: await _headers(),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(res.body)['conversation']);
    }
    throw Exception('Failed to join arena group (${res.statusCode})');
  }
}

class ArenaGroupInfo {
  final int interestId;
  final String interestName;
  final int conversationId;
  final int memberCount;
  final bool isMember;

  ArenaGroupInfo({
    required this.interestId,
    required this.interestName,
    required this.conversationId,
    required this.memberCount,
    required this.isMember,
  });

  factory ArenaGroupInfo.fromJson(Map<String, dynamic> json) {
    return ArenaGroupInfo(
      interestId: json['interest_id'] ?? 0,
      interestName: json['interest_name'] ?? '',
      conversationId: json['conversation_id'] ?? 0,
      memberCount: json['member_count'] ?? 0,
      isMember: json['is_member'] ?? false,
    );
  }
}

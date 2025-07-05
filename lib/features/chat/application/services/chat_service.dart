import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/chat_models.dart';
import '../../../../shared/utils/storage.dart';

/// Service class to load the available friends and groups from the API.
class ChatService {
  static const String _baseUrl = 'http://10.0.2.2:8002';

  /// Loads the available chats.
  static Future<Map<String, dynamic>> fetchAvailableChats() async {
    // Retrieve access token stored after login.
    final accessToken = await Storage.getToken();
    print(accessToken);
    final response = await http.get(
      Uri.parse('$_baseUrl/api/chats/available/'),
      headers: {
        'Authorization': 'bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Parse friends and groups from JSON.
      final friends = (data['friends'] as List)
          .map((f) => Friend.fromJson(f))
          .toList();

      final groups = (data['groups'] as List)
          .map((g) => ChatGroup.fromJson(g))
          .toList();

      return {'friends': friends, 'groups': groups};
    } else {
      print(response);
      throw Exception(
        'Failed to load chats: ${response.statusCode} ${response.body}',
      );
    }
  }
}

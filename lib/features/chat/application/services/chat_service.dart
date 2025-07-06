import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/chat_models.dart';
import '../../../../shared/services/auth_helper.dart'; // Import your TokenManager

/// Service class responsible for fetching available chats from the API.
class ChatService {
  // Base URL pointing to your Django backend.
  static const String _baseUrl = 'http://10.0.2.2:8002';

  /// Fetches the available friends and groups for the current user.
  static Future<Map<String, dynamic>> fetchAvailableChats() async {
    // Ensure we have a valid access token (refresh if expired)
    final accessToken = await TokenManager.ensureValidToken();
    if (accessToken == null) {
      throw Exception('Could not retrieve a valid access token.');
    }

    // Make an authenticated GET request to the endpoint.
    final response = await http.get(
      Uri.parse('$_baseUrl/api/chats/available/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse JSON response.
      final data = jsonDecode(response.body);

      // Map each friend JSON into Friend model.
      final friends = (data['friends'] as List)
          .map((f) => Friend.fromJson(f))
          .toList();

      // Map each group JSON into ChatGroup model.
      final groups = (data['groups'] as List)
          .map((g) => ChatGroup.fromJson(g))
          .toList();

      // Return a map containing both lists.
      return {'friends': friends, 'groups': groups};
    } else {
      // If not 200, throw an error with details.
      throw Exception(
        'Failed to load chats: ${response.statusCode} ${response.body}',
      );
    }
  }
}

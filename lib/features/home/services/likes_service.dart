import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/utils/storage.dart';

class LikesService {
  static const String baseUrl = 'http://10.0.2.2:8001/api/';

  // Add like to a post
  static Future<Map<String, dynamic>> addLike(int postId) async {
    try {
      final userId = await Storage.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${baseUrl}social-service/features/addLike?userId=$userId&postId=$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add like: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add like: $e');
    }
  }

  // Remove like from a post
  static Future<Map<String, dynamic>> removeLike(int postId) async {
    try {
      final userId = await Storage.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${baseUrl}social-service/features/removeLike/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'postId': postId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to remove like: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove like: $e');
    }
  }
}

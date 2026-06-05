import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

import 'package:assistrend/config/app_config.dart';
import 'package:assistrend/shared/utils/storage.dart';

class SocialService {
  static final String baseUrl = '${AppConfig.socialServerUrl}/api/social-service/features/';

  static Future<Map<String, String>> _headers() async {
    final token = await Storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Like a post
  static Future<bool> likePost(int postId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}addLike/?postId=$postId&userId=$userId'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // Unlike a post
  static Future<bool> unlikePost(int postId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}removeLike/'),
        headers: await _headers(),
        body: jsonEncode({
          'postId': postId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  // Add a comment
  static Future<bool> addComment(int postId, String userId, String comment) async {
    try {
      print('Adding comment: postId=$postId, userId=$userId, comment=$comment');
      
      final response = await http.post(
        Uri.parse('${baseUrl}addComment/'),
        headers: await _headers(),
        body: jsonEncode({
          'postId': postId,
          'userId': userId,
          'comment': comment,
        }),
      );

      print('Add comment response: ${response.statusCode}');
      print('Add comment response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get comments for a post
  static Future<List<Comment>> getComments(int postId) async {
    try {
      print('Fetching comments for post: $postId');
      
      final response = await http.get(
        Uri.parse('${baseUrl}getComment/?postId=$postId'),
        headers: await _headers(),
      );

      print('Get comments response: ${response.statusCode}');
      print('Get comments response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> commentsData = data['comments'];
          // For now, we'll create comments without usernames as the backend doesn't provide them
          // In a real app, you might want to fetch user details separately
          return commentsData.map((commentJson) {
            return Comment(
              id: commentJson['id'],
              userId: commentJson['user_id'],
              comment: commentJson['comment'],
              createdAt: DateTime.parse(commentJson['created_at']),
              username: 'User ${commentJson['user_id']}', // Placeholder username
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }
}

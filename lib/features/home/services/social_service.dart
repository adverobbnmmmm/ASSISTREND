import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

class SocialService {
  static const String baseUrl = 'https://social-service-aemo.onrender.com/api/social-service/features/';

  // Like a post
  static Future<bool> likePost(int postId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}addLike/?postId=$postId&userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
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
  static Future<bool> unlikePost(int postId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}removeLike/'),
        headers: {
          'Content-Type': 'application/json',
        },
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
  static Future<bool> addComment(int postId, int userId, String comment) async {
    try {
      print('Adding comment: postId=$postId, userId=$userId, comment=$comment');
      
      final response = await http.post(
        Uri.parse('${baseUrl}addComment/'),
        headers: {
          'Content-Type': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
        },
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

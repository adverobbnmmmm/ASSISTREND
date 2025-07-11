import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/utils/storage.dart';

class Comment {
  final int id;
  final int userId;
  final String comment;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.comment,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CommentsService {
  static const String baseUrl = 'http://10.0.2.2:8001/api/';

  // Get comments for a post
  static Future<List<Comment>> getComments(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}social-service/features/getComment?postId=$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> commentsJson = data['comments'];
          return commentsJson.map((json) => Comment.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get comments');
        }
      } else {
        throw Exception('Failed to get comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Add a comment to a post
  static Future<Map<String, dynamic>> addComment(int postId, String comment) async {
    try {
      final userId = await Storage.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${baseUrl}social-service/features/addComment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'postId': postId,
          'userId': userId,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
}

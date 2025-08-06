import 'dart:convert';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:http/http.dart' as http;

class SocialApiService {
  static const String baseUrl = 'https://social-service-aemo.onrender.com/api/'; // Social service on port 8001

  static Future<dynamic> _makeRequest(
    String endpoint,
    Map<String, dynamic>? body,
    String method,
    String? token,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl$endpoint');
    http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'GET':
          response = await http.get(
            uri,
            headers: headers,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: headers,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For empty responses
        if (response.body.isEmpty) {
          return {};
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Social API request failed: $e');
    }
  }

  // Get Profile Data by User ID
  static Future<Map<String, dynamic>> getProfileData(int userId) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/profile?userId=$userId',
      null,
      'GET',
      token,
    );
  }

  // Update Profile
  static Future<dynamic> updateProfile(int userId, Map<String, dynamic> profileData) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/profile?userId=$userId',
      profileData,
      'PUT',
      token,
    );
  }

  // Create Post
  static Future<dynamic> createPost(String caption, String imageUrl) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/posts',
      {
        'caption': caption,
        'image_url': imageUrl,
      },
      'POST',
      token,
    );
  }

  // Like Post
  static Future<dynamic> likePost(int postId) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/posts/$postId/like',
      {},
      'POST',
      token,
    );
  }

  // Unlike Post
  static Future<dynamic> unlikePost(int postId) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/posts/$postId/unlike',
      {},
      'POST',
      token,
    );
  }

  // Get User Stories
  static Future<dynamic> getUserStories(int userId) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/stories?userId=$userId',
      null,
      'GET',
      token,
    );
  }

  // Update Name
  static Future<dynamic> updateName(int userId, String name) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/update-name/',
      {'userId': userId.toString(), 'name': name},
      'POST',
      token,
    );
  }

  // Update About
  static Future<dynamic> updateAbout(int userId, String about) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/update-about/',
      {'userId': userId.toString(), 'about': about},
      'POST',
      token,
    );
  }

  // Update Emoji
  static Future<dynamic> updateEmoji(int userId, String emoji) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/update-emoji/',
      {'userId': userId.toString(), 'emoji': emoji},
      'POST',
      token,
    );
  }

  // Update Interests
  static Future<dynamic> updateInterests(int userId, List<String> interests) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/update-interests/',
      {'userId': userId.toString(), 'interests': interests},
      'POST',
      token,
    );
  }

  // Update Socials
  static Future<dynamic> updateSocials(int userId, String platform, String url) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    return await _makeRequest(
      'social-service/features/update-socials/',
      {'userId': userId.toString(), 'platform': platform, 'url': url},
      'POST',
      token,
    );
  }
}
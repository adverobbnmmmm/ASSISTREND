import 'dart:convert';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:http/http.dart' as http;

import 'package:assistrend/config/app_config.dart';

class SocialApiService {
  static final String _socialBaseUrl = AppConfig.socialApiBaseUrl;

  static Future<dynamic> _makeRequest(
    String baseUrl,
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
        if (response.body.isEmpty) {
          return {};
        }
        return jsonDecode(response.body);
      } else {
        if (response.body.isNotEmpty) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map<String, dynamic>) {
              throw Exception(
                decoded['error'] ??
                    decoded['message'] ??
                    decoded['detail'] ??
                    'Request failed: ${response.statusCode}',
              );
            }
          } catch (_) {}
        }
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Social API request failed: $e');
    }
  }

  static Future<String> _requireToken() async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }

  // Get profile data by user ID
  static Future<Map<String, dynamic>> getProfileData(String userId) async {
    final token = await _requireToken();
    final data = await _makeRequest(
      _socialBaseUrl,
      'features/profile?userId=$userId',
      null,
      'GET',
      token,
    );
    return (data as Map<String, dynamic>);
  }

  // Update profile
  static Future<dynamic> updateProfile(String userId, Map<String, dynamic> profileData) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/profile?userId=$userId',
      profileData,
      'PUT',
      token,
    );
  }

  // Create post
  static Future<dynamic> createPost(String caption, String imageUrl) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/uploadPost/',
      {
        'caption': caption,
        'imageUrl': imageUrl,
      },
      'POST',
      token,
    );
  }

  // Like post
  static Future<dynamic> likePost(int postId) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/addLike/?postId=$postId',
      null,
      'GET',
      token,
    );
  }

  // Unlike post
  static Future<dynamic> unlikePost(int postId) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/removeLike/',
      {'postId': postId},
      'POST',
      token,
    );
  }

  // Get user stories
  static Future<dynamic> getUserStories(String userId) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/stories/?userId=$userId',
      null,
      'GET',
      token,
    );
  }

  // Update name
  static Future<dynamic> updateName(String userId, String name) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-name/',
      {'userId': userId, 'name': name},
      'POST',
      token,
    );
  }

  // Update about
  static Future<dynamic> updateAbout(String userId, String about) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-about/',
      {'userId': userId, 'about': about},
      'POST',
      token,
    );
  }

  // Update emoji
  static Future<dynamic> updateEmoji(String userId, String emoji) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-emoji/',
      {'userId': userId, 'emoji': emoji},
      'POST',
      token,
    );
  }

  // Update interests
  static Future<dynamic> updateInterests(String userId, List<String> interests) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-interests/',
      {'userId': userId, 'interests': interests},
      'POST',
      token,
    );
  }

  // Update socials
  static Future<dynamic> updateSocials(String userId, String platform, String url) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-socials/',
      {'userId': userId, 'platform': platform, 'url': url},
      'POST',
      token,
    );
  }

  // Update profile audio URL
  static Future<dynamic> updateProfileAudio(String userId, String? audioUrl) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-profile-audio/',
      {'userId': userId, 'audioUrl': audioUrl},
      'POST',
      token,
    );
  }

  // Update profile photo URL
  static Future<dynamic> updateProfilePhoto(String userId, String? photoUrl) async {
    final token = await _requireToken();
    return await _makeRequest(
      _socialBaseUrl,
      'features/update-profile-photo/',
      {'userId': userId, 'profileImageUrl': photoUrl},
      'POST',
      token,
    );
  }
}

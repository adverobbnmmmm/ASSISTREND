import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/'; // Replace with your actual backend URL

  // Helper method for making requests
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
        default:
          throw Exception('Unsupported HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  // User Registration
  static Future<dynamic> register(
      String name, String email,String phone, String password,bool privacy_policy_accepted) async {
    return await _makeRequest(
      'account/register/',
      {
        'name': name,
        'email': email,
        'phone':phone,
        'password': password,
        'privacy_policy_accepted':privacy_policy_accepted,
      },
      'POST',
      null,
    );
  }

  // OTP Verification
  static Future<dynamic> verifyOTP(String email, String otp) async {
    return await _makeRequest(
      'account/verify_otp/',
      {
        'email': email,
        'otp': otp,
      },
      'POST',
      null,
    );
  }

  // User Login
  static Future<dynamic> login(String email, String password) async {
    return await _makeRequest(
      'account/login/',
      {
        'email': email,
        'password': password,
      },
      'POST',
      null,
    );
  }

  // User Logout
  static Future<dynamic> logout(String token) async {
    return await _makeRequest(
      'account/logout/',
      null,
      'POST',
      token,
    );
  }

  // Get User Profile
  static Future<dynamic> getProfile(String token) async {
    return await _makeRequest(
      'account/profile/',
      null,
      'GET',
      token,
    );
  }
}
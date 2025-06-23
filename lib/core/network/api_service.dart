import 'dart:convert';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/'; 

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
        // For empty responses
        if (response.body.isEmpty) {
          return {};
        }
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
      String name, String email, String phone, String password, bool privacy_policy_accepted) async {
    return await _makeRequest(
      'account/register/',
      {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'privacy_policy_accepted': privacy_policy_accepted,
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
        'otpCode': otp,
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
  static Future<void> logout(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}account/logout/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
        body: json.encode({
          'refresh_token': refreshToken,
        }),
      );
      
      if (response.statusCode != 205) {
        throw Exception('Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Logout request failed: $e');
    }
  }

  // Get User Profile (basic info from auth service)
  static Future<dynamic> getProfile(String token) async {
    return await _makeRequest(
      'account/profile/',
      null,
      'GET',
      token,
    );
  }

  // Change Password
  static Future<dynamic> changePassword(String oldPassword, String newPassword) async {
    final token = await Storage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    return await _makeRequest(
      'account/change-password/',
      {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
      'POST',
      token,
    );
  }

  // Request Password Reset
  static Future<dynamic> requestPasswordReset(String email) async {
    return await _makeRequest(
      'account/request-password-reset/',
      {'email': email},
      'POST',
      null,
    );
  }

  // Reset Password with Token
  static Future<dynamic> resetPassword(String token, String password) async {
    return await _makeRequest(
      'account/reset-password/',
      {
        'token': token,
        'password': password,
      },
      'POST',
      null,
    );
  }
}
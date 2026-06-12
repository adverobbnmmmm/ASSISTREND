import 'dart:convert';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:http/http.dart' as http;

import 'package:assistrend/config/app_config.dart';

class ApiService {
  static final String baseUrl = AppConfig.apiBaseUrl;
  static final String socialServiceUrl = AppConfig.socialApiBaseUrl;

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
    
    // Debug logging
    print('DEBUG API: Making $method request to: $uri');
    print('DEBUG API: Headers: $headers');
    print('DEBUG API: Body: ${jsonEncode(body)}');
    
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
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      print('DEBUG API: Response status: ${response.statusCode}');

      if (response.statusCode == 401 &&
          !endpoint.contains('refresh_token') &&
          !endpoint.contains('login')) {
        // Attempt automatic token refresh
        final refreshToken = await Storage.getRefreshToken();
        if (refreshToken != null) {
          try {
            print('DEBUG API: Access token expired (401). Attempting automatic refresh...');
            final refreshResponse = await refreshAccessToken(refreshToken);
            final newAccessToken = refreshResponse['access'];
            if (newAccessToken != null) {
              await Storage.saveToken(newAccessToken);
              print('DEBUG API: Refresh successful. Retrying original request to: $endpoint');
              // Re-run the request with the new access token
              return await _makeRequest(endpoint, body, method, newAccessToken);
            }
          } catch (refreshErr) {
            print('DEBUG API: Automatic token refresh failed: $refreshErr');
            await Storage.clearAllTokens();
          }
        }
      }
      print('DEBUG API: Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For empty responses
        if (response.body.isEmpty) {
          return {};
        }
        return jsonDecode(response.body);
      } else {
        // Try to parse error message from response body
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            // Look for common error message fields
            if (errorData.containsKey('message')) {
              throw Exception(errorData['message']);
            } else if (errorData.containsKey('error')) {
              throw Exception(errorData['error']);
            } else if (errorData.containsKey('detail')) {
              throw Exception(errorData['detail']);
            }
          }
        } catch (e) {
          // If JSON parsing fails, fall back to status code error
        }
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  // User Registration
  static Future<dynamic> register(
      String name, String email, String phone, String password, bool privacy_policy_accepted) async {
    // Legacy single-screen signup compatibility wrapper.
    // The current backend supports only multi-step signup endpoints.
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = name.trim().replaceAll(RegExp(r'\s+'), '_');

    await _makeRequest(
      'v1/accounts/auth/signup/step_1/',
      {
        'email': normalizedEmail,
        'username': normalizedUsername,
        'session_id': sessionId,
      },
      'POST',
      null,
    );

    await _makeRequest(
      'v1/accounts/auth/signup/step_2/',
      {
        'password': password,
        'confirm_password': password,
        'session_id': sessionId,
      },
      'POST',
      null,
    );

    // Old signup screen does not collect gender/DOB; use safe defaults.
    await _makeRequest(
      'v1/accounts/auth/signup/step_3/',
      {
        'gender': 'other',
        'date_of_birth': '2000-01-01',
        'session_id': sessionId,
      },
      'POST',
      null,
    );

    await _makeRequest(
      'v1/accounts/auth/signup/step_4/',
      {
        'phone_number': phone,
        'session_id': sessionId,
      },
      'POST',
      null,
    );

    await _makeRequest(
      'v1/accounts/auth/signup/step_5/',
      {
        'privacy_policy_accepted': privacy_policy_accepted,
        'session_id': sessionId,
      },
      'POST',
      null,
    );

    return await _makeRequest(
      'v1/accounts/auth/signup/complete/',
      {
        'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Multi-step Signup - Step 1: Email and Username
  static Future<dynamic> signupStep1(String email, String username, {String? sessionId}) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/step_1/',
      {
        'email': email,
        'username': username,
        if (sessionId != null) 'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Multi-step Signup - Step 2: Password
  static Future<dynamic> signupStep2(String password, String confirmPassword, {required String sessionId}) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/step_2/',
      {
        'password': password,
        'confirm_password': confirmPassword,
        'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Multi-step Signup - Step 3: Personal Info
  static Future<dynamic> signupStep3(String gender, String dateOfBirth, {required String sessionId}) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/step_3/',
      {
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Multi-step Signup - Step 4: Phone Number
  static Future<dynamic> signupStep4(String phoneNumber, {required String sessionId}) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/step_4/',
      {
        'phone_number': phoneNumber,
        'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Multi-step Signup - Step 5: Privacy Policy
  static Future<dynamic> signupStep5(bool privacyPolicyAccepted, {required String sessionId}) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/step_5/',
      {
        'privacy_policy_accepted': privacyPolicyAccepted,
        'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Multi-step Signup - Complete
  static Future<dynamic> signupComplete({required String sessionId}) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/complete/',
      {
        'session_id': sessionId,
      },
      'POST',
      null,
    );
  }

  // Validate email availability
  static Future<dynamic> validateEmail(String email) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/validate_email/',
      {'email': email},
      'POST',
      null,
    );
  }

  // Validate username availability
  static Future<dynamic> validateUsername(String username) async {
    return await _makeRequest(
      'v1/accounts/auth/signup/validate_username/',
      {'username': username},
      'POST',
      null,
    );
  }

  // OTP Verification
  static Future<dynamic> verifyOTP(String email, String otp) async {
    final otpResult = await verifyEmailOTP(email, otp);
    if (otpResult['success'] == true) {
      // After successful OTP verification, exchange email for JWT tokens.
      return await oauthCallback(email);
    }
    return otpResult;
  }

  // Email Verification - Send OTP
  static Future<dynamic> sendEmailOTP(String email, {String verificationType = 'email'}) async {
    return await _makeRequest(
      'v1/accounts/auth/email-verification/send_otp/',
      {
        'email': email,
        'verification_type': verificationType,
      },
      'POST',
      null,
    );
  }

  // Email Verification - Verify OTP
  static Future<dynamic> verifyEmailOTP(String email, String otpCode) async {
    final uri = Uri.parse('${baseUrl}v1/accounts/auth/email-verification/verify_otp/');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp_code': otpCode,
      }),
    );

    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
      }
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected verify OTP response format');
  }

  // Email Verification - Resend OTP
  static Future<dynamic> resendEmailOTP(String email) async {
    return await _makeRequest(
      'v1/accounts/auth/email-verification/resend_otp/',
      {'email': email},
      'POST',
      null,
    );
  }

  // User Login with email and password
  static Future<dynamic> login(String email, String password) async {
    return await _makeRequest(
      'v1/accounts/auth/auth/login/',
      {
        'email': email,
        'password': password,
      },
      'POST',
      null,
    );
  }

  // User Logout
  static Future<dynamic> logout(String refreshToken) async {
    return await _makeRequest(
      'v1/accounts/auth/auth/logout/',
      {
        'refresh_token': refreshToken,
      },
      'POST',
      null,
    );
  }

  // Refresh access token
  static Future<dynamic> refreshAccessToken(String refreshToken) async {
    return await _makeRequest(
      'v1/accounts/auth/auth/refresh_token/',
      {
        'refresh': refreshToken,
      },
      'POST',
      null,
    );
  }

  // Google OAuth login
  static Future<dynamic> googleLogin(String googleToken) async {
    return await _makeRequest(
      'v1/accounts/auth/auth/google_login/',
      {
        'token': googleToken,
      },
      'POST',
      null,
    );
  }

  // OAuth callback after email verification
  static Future<dynamic> oauthCallback(String email) async {
    return await _makeRequest(
      'v1/accounts/auth/auth/oauth_callback/',
      {
        'email': email,
      },
      'POST',
      null,
    );
  }

  // Get User Profile (basic info from auth service)
  static Future<dynamic> getProfile(String token) async {
    return await _makeRequest(
      'v1/accounts/profile/me/',
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

  // Get Posts Feed from Social Service
  static Future<List<dynamic>> getPostsFeed() async {
    try {
      final token = await Storage.getToken();
      final url = '${socialServiceUrl}features/getPostUserFeed';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> posts = jsonDecode(response.body);
        return posts;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  static Future<dynamic> setupProfile(String userId, dynamic profileData) async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/me/',
      {
        'userId': userId,
        ...profileData.toJson(),
      },
      'PUT',
      token,
    );
  }

  static Future<dynamic> getInterests() async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/interests/',
      null,
      'GET',
      token,
    );
  }

  static Future<dynamic> checkProfileExists(String userId) async {
    final token = await Storage.getToken();
    if (token == null) {
      return {'profileExists': false};
    }

    final uri = Uri.parse('${baseUrl}v1/accounts/profile/me/');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {'profileExists': true};
    }
    if (response.statusCode == 404) {
      return {'profileExists': false};
    }

    throw Exception('Failed to check profile: ${response.statusCode}');
  }

  static Future<dynamic> getUserProfile(String userId) async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/me/',
      null,
      'GET',
      token,
    );
  }

  // Get another user's profile by id (read-only)
  static Future<dynamic> getProfileById(String userId) async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/$userId/',
      null,
      'GET',
      token,
    );
  }

  static Future<dynamic> updateProfile(Map<String, dynamic> data) async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/me/',
      data,
      'PATCH',
      token,
    );
  }

  // Test endpoint for debugging
  // Community Champion: Apply
  static Future<dynamic> applyForChampion(List<int> specializedInterestIds) async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/champion/apply/',
      {'specialized_interests': specializedInterestIds},
      'POST',
      token,
    );
  }

  // Community Champion: Status
  static Future<dynamic> getChampionStatus() async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/champion/status/',
      null,
      'GET',
      token,
    );
  }

  // Community Champion: Users under champion's specialized interest domains
  static Future<dynamic> getChampionUsers() async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'v1/accounts/profile/champion/users/',
      null,
      'GET',
      token,
    );
  }

  static Future<dynamic> testDatabase() async {
    final token = await Storage.getToken();
    return await _makeRequest(
      'account/test-database/',
      null,
      'GET',
      token,
    );
  }
}

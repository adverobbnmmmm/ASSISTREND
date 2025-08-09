import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/utils/storage.dart';

class TokenManager {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// Ensure the token is valid.
  /// Returns a usable access token, refreshing if necessary.
  static Future<String?> ensureValidToken() async {
    final accessToken = await Storage.getToken();
    if (accessToken == null) {
      print("No access token stored.");
      return null;
    }

    // Check expiry locally
    if (_isTokenExpired(accessToken)) {
      print("Access token expired, attempting refresh...");
      final refreshed = await _refreshToken();
      if (refreshed != null) {
        return refreshed;
      }
      return null;
    } else {
      return accessToken;
    }
  }

  /// Decodes the token and checks if expired.
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print("Invalid JWT structure.");
        return true; // consider expired
      }

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;
      final exp = payloadMap['exp'] as int?;
      if (exp == null) {
        print("No 'exp' claim found.");
        return true;
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now().toUtc();
      final isExpired = expiryDate.isBefore(now);
      return isExpired;
    } catch (e) {
      print("Error decoding token: $e");
      return true;
    }
  }

  /// Refreshes the token and saves it.
  static Future<String?> _refreshToken() async {
    final refresh = await Storage.getRefreshToken();
    if (refresh == null) {
      print("No refresh token stored.");
      return null;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccess = data['access'] as String?;
      if (newAccess != null) {
        await Storage.saveToken(newAccess);
        print("Access token refreshed successfully.");
        return newAccess;
      }
    }

    print("Failed to refresh token: ${response.body}");
    await Storage.clearAllTokens();
    return null;
  }
}

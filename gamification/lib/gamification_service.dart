import 'dart:convert';
import 'package:http/http.dart' as http;

class GamificationService {
  final String baseUrl = "http://10.0.2.2:8000/api/gamification-service/gamification-points/";

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
    return false;
  }
}

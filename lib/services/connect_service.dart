// lib/services/connect_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ConnectService {
  static const String baseUrl = 'https://domain.com/api/connect-service'; // 👈 Replace with your real URL

  static Future<List<dynamic>> getConnectedUsers() async {
    final url = Uri.parse('$baseUrl/connect-users/matches/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Connected users: ${response.body}');
        return json.decode(response.body); // return the user list
      } else {
        print('Failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
  static Future<List<Map<String, dynamic>>> fetchInterests() async {
      final response = await http.get(Uri.parse('$baseUrl/connect-users/interests/'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load interests');
      }
    }

    static Future<void> sendInterests(List<int> selectedInterestIds) async {
      final response = await http.post(
        Uri.parse('$baseUrl/connect-users/add-interests/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'interestIds': selectedInterestIds}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send interests');
      }
    }

}

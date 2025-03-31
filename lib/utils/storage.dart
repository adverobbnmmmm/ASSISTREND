import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<void> saveToken(String access) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
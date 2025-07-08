import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  print('Current token: $token');
  await prefs.remove('access_token');
  print('Token removed. New value: ${prefs.getString('access_token')}');
}

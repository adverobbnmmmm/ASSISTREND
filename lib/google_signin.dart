import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '657499594632-ota692hjv442mjfle75c35fv4noeq67b.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);


  static Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      // Send the accessToken to your Django backend for verification
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/google/'),  // Adjust this URL to your Django backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'access_token': accessToken,
          'id_token': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String backendAccessToken = responseData['access'];

        // Save the backend access token (use SharedPreferences or similar)
        print("Successfully authenticated: $backendAccessToken");
      } else {
        print("Google Sign-In failed. Server response: ${response.body}");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
    }
  }
}

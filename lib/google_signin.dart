import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile', 'openid'],
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GoogleSignInPage(),
    );
  }
}

class GoogleSignInPage extends StatefulWidget {
  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  GoogleSignInAccount? _user;

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      // You'll need to send these tokens to your Django Backend
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      print("Access Token: $accessToken");
      print("ID Token: $idToken");

      // Send tokens to your Django backend for verification and authentication
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/google/'),
        body: {'access_token': accessToken, 'id_token': idToken},
      );

      if (response.statusCode == 200) {
        print('Login Successful');
      } else {
        print('Login Failed');
      }

      setState(() {
        _user = googleUser;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Login Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: signInWithGoogle,
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}

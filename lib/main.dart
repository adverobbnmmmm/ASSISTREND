import 'package:assistrend/presentation/home/homepage.dart';
import 'package:flutter/material.dart';
import 'assistrend_opening.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assistrend_signup.dart';
import 'assistrend_login.dart';
//import 'google_signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  runApp(MyApp(initialRoute: token != null ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistrend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blueAccent,
          selectionColor: Colors.blueAccent,
          selectionHandleColor: Colors.blue,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => AssistrendOpening(),
        '/login': (context) => AssistrendLogin(),
        '/signup': (context) => AssistrendSignUp(),
        '/home': (context) => HomePage(),
        // '/google':(context) => GoogleSignInPage(),
      },
    );
  }
}

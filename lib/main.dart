import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
// Conditionally import Firebase packages
import 'package:firebase_core/firebase_core.dart' if (dart.library.js_util) '' as firebase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeFirebase();  
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  try {
    // Only initialize Firebase on supported platforms
    if (!kIsWeb && !(Platform.isWindows)) {
      await firebase.Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase initialization skipped on this platform');
    }  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Assistrend',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blueAccent,
          selectionColor: Colors.blueAccent,
          selectionHandleColor: Colors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
      // Use the router configuration from the AppRouter class
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

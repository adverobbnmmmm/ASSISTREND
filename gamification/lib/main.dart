import 'package:flutter/material.dart';
import 'gamification_form_page.dart';

void main() {
  runApp(const GamificationApp());
}

class GamificationApp extends StatelessWidget {
  const GamificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Gamification Demo",
      theme: ThemeData.dark(),
      home: const GamificationFormPage(), // points to the page above
    );
  }
}

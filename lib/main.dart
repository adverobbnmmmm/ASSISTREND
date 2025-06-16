import 'package:flutter/material.dart';
import 'assistrend_opening.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistrend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AssistrendOpening(), // Start with the splash screen
    );
  }
}

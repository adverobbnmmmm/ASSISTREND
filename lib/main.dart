import 'package:flutter/material.dart';
import 'assistrend_opening.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistrend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AssistrendOpening(), // Start with the splash screen
    );
  }
}

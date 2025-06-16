import 'dart:async';
import 'package:flutter/material.dart';
import 'assistrend_login.dart'; // Import your signup page

class AssistrendOpening extends StatefulWidget {
  @override
  _AssistrendOpeningState createState() => _AssistrendOpeningState();
}

class _AssistrendOpeningState extends State<AssistrendOpening> {
  @override
  void initState() {
    super.initState();
    
    // Timer to navigate to the signup page after 1 second
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AssistrendLogin()),
      );
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 59, 15, 179), Color.fromARGB(255, 31, 29, 150)], // Define your gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'ASSISTREND',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
}

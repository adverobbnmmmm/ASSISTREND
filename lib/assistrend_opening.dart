import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssistrendOpening extends StatefulWidget {
  @override
  _AssistrendOpeningState createState() => _AssistrendOpeningState();
}

class _AssistrendOpeningState extends State<AssistrendOpening> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _serverOnline = false;
  bool _checkingServer = true;
  String _serverMessage = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();

    _loopCheckServerAndNavigate();
  }

  Future<void> _loopCheckServerAndNavigate() async {
    const String serverUrl = 'http://10.0.2.2:8000/api/account/checkServerStatus';
    while (mounted && !_serverOnline) {
      print('Checking server status...');
      try {
        final response = await http.get(Uri.parse(serverUrl)).timeout(Duration(seconds: 2));
        print('Server response: '
            'Status: ${response.statusCode} '
            'Body: ${response.body}');
        if (response.statusCode == 200) {
          setState(() {
            _serverOnline = true;
            _serverMessage = '';
          });
          await _checkAuthAndNavigate();
          break; // Stop checking once online
        } else {
          setState(() {
            _serverOnline = false;
            _serverMessage = 'Please wait till server becomes online';
          });
        }
      } catch (e) {
        print('Error in server check: $e');
        setState(() {
          _serverOnline = false;
          _serverMessage = 'Please wait till server becomes online';
        });
      }
      await Future.delayed(Duration(seconds: 2));
    }
  }
  
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getInt('user_id');
    print('DEBUG: Token in opening screen: $token, UserId: $userId');
    final isLoggedIn = token != null && userId != null;
    if (!mounted) return;
    try {
      if (isLoggedIn) {
        // Fetch user name from backend and store in SharedPreferences
        try {
          final url = Uri.parse('http://10.0.2.2:8000/api/account/getName/?userId=$userId');
          final response = await http.get(url);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final name = data['name'] ?? '';
            await prefs.setString('user_name', name);
            print('DEBUG: Stored user_name: $name');
          } else {
            await prefs.setString('user_name', '');
            print('DEBUG: Failed to fetch name, status: ${response.statusCode}');
          }
        } catch (e) {
          await prefs.setString('user_name', '');
          print('DEBUG: Error fetching name: $e');
        }
        print('User is logged in, navigating to home');
        context.go('/home');
      } else {
        print('User is not logged in, navigating to login');
        context.go('/login');
      }
    } catch (e) {
      print('Navigation error in opening screen: $e');
      context.go('/login');
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 59, 15, 179), Color.fromARGB(255, 31, 29, 150)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ASSISTREND',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      if (!_serverOnline && _serverMessage.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Text(
                          _serverMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

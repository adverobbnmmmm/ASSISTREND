import 'package:flutter/material.dart';

import '../../../core/network/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import 'package:go_router/go_router.dart';

class AssistrendSignUp extends ConsumerStatefulWidget {
  @override
  _AssistrendSignUpState createState() => _AssistrendSignUpState();
}

class _AssistrendSignUpState extends ConsumerState<AssistrendSignUp> {
  bool isRememberMeChecked = false;
  bool _privacyPolicyAccepted = false;
  final TextEditingController _nameController = TextEditingController(text: 'jefin10');
  final TextEditingController _emailController = TextEditingController(text: 'jefinfrancis4u@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'jefin@123J');
  final TextEditingController _phoneController = TextEditingController(text: '9946381688');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.error) {
        _showError(authState.errorMessage ?? 'Registration error');
      }
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleSignUp() async {
    // Validate form fields
    if (_nameController.text.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }
    
    if (!_privacyPolicyAccepted) {
      _showError('Please accept the privacy policy');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the Riverpod provider to register
      await ref.read(authProvider.notifier).register(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
        _privacyPolicyAccepted,
      );

      // Debug logging
      print('DEBUG: Registration completed, navigating to OTP verification');
      print('DEBUG: Email: ${_emailController.text}');
      
      // Navigate to OTP screen
      if (mounted) {
        print('DEBUG: About to navigate to OTP screen');
        context.go('/otp-verification?email=${Uri.encodeComponent(_emailController.text)}');
        print('DEBUG: Navigation command sent');
      }
    } catch (e) {
      print('DEBUG: Registration failed with error: $e');
      _showError('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://assistrend.com/');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authProvider, (previous, current) {
      print('DEBUG: Auth state changed in signup');
      print('DEBUG: Previous status: ${previous?.status}');
      print('DEBUG: Current status: ${current.status}');
      
      if (current.status == AuthStatus.error && current.errorMessage != null) {
        print('DEBUG: Registration error: ${current.errorMessage}');
        _showError(current.errorMessage!);
      } else if (current.status == AuthStatus.unauthenticated && previous?.status == AuthStatus.registering) {
        print('DEBUG: Registration successful, should navigate to OTP');
        // This is where we should navigate to OTP, but we're doing it after the API call instead
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              SizedBox(height: 30),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Go back
                  },
                ),
              ),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter your username',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter your phone number',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Create your password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _privacyPolicyAccepted, //Privacy policy checkbox
                    onChanged: (bool? newValue) {
                      setState(() {
                        _privacyPolicyAccepted = newValue ?? false;
                      });
                    },
                    activeColor: Colors.blueAccent,
                    checkColor: Colors.white,
                  ),
                  InkWell(
                    onTap: (_launchURL),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Accept ',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 40, 108, 224),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              SizedBox(height: 20),
              
             
              
              // Or login with
            ],
          ),
        ),
      ),
    );
  }
}

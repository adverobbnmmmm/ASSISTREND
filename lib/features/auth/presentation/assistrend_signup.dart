import 'package:flutter/material.dart';

import '../../../core/network/api_service.dart';
import 'otp_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';

class AssistrendSignUp extends ConsumerStatefulWidget {
  @override
  _AssistrendSignUpState createState() => _AssistrendSignUpState();
}

class _AssistrendSignUpState extends ConsumerState<AssistrendSignUp> {
  bool isRememberMeChecked = false;
  bool _privacyPolicyAccepted = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _passwordError;

  bool _isPasswordValid(String password) {
    // Check if password meets backend requirements
    if (password.length < 8 || password.length > 25) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false; // lowercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false; // uppercase
    if (!password.contains(RegExp(r'[0-9]'))) return false; // number
    if (!password.contains(RegExp(r'[@$!%*?&]'))) return false; // special char
    return true;
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  String _getPasswordErrorMessage(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (password.length > 25) return 'Password must be less than 25 characters';
    if (!password.contains(RegExp(r'[a-z]'))) return 'Password must contain a lowercase letter';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Password must contain an uppercase letter';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Password must contain a number';
    if (!password.contains(RegExp(r'[@$!%*?&]'))) return 'Password must contain a special character (@\$!%*?&)';
    return '';
  }

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
    // Validate all fields before proceeding
    if (_nameController.text.trim().isEmpty) {
      _showError('Name is required');
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showError('Email is required');
      return;
    }
    
    if (!_isEmailValid(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      _showError('Phone number is required');
      return;
    }
    
    if (!_isPasswordValid(_passwordController.text)) {
      _showError(_getPasswordErrorMessage(_passwordController.text));
      return;
    }
    
    if (!_privacyPolicyAccepted) {
      _showError('You must accept the privacy policy to register');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the Riverpod provider to register
      await ref.read(authProvider.notifier).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _privacyPolicyAccepted,
      );

      // Navigate to OTP screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
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
      if (current.status == AuthStatus.error && current.errorMessage != null) {
        _showError(current.errorMessage!);
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _passwordError = _isPasswordValid(value) ? null : _getPasswordErrorMessage(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Create your password',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _passwordError != null ? Colors.red : Colors.blueAccent,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _passwordError != null ? Colors.red : Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_passwordController.text.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password requirements:',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• 8-25 characters\n• Uppercase letter (A-Z)\n• Lowercase letter (a-z)\n• Number (0-9)\n• Special character (@\$!%*?&)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_passwordController.text.isNotEmpty && _passwordError == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Password meets all requirements',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}

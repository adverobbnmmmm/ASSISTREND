import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import 'package:go_router/go_router.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String email;

  const OTPScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _verifyOTP() async {
    // Validate OTP input
    if (_otpController.text.isEmpty) {
      _showError('Please enter the OTP code');
      return;
    }
    
    if (_otpController.text.length != 6) {
      _showError('OTP must be 6 digits');
      return;
    }

    // Additional validation: ensure OTP is numeric
    if (!RegExp(r'^\d{6}$').hasMatch(_otpController.text)) {
      _showError('OTP must be exactly 6 digits');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Print what we're sending
      print('DEBUG: Verifying OTP for email: ${widget.email}');
      print('DEBUG: OTP code: ${_otpController.text}');
      print('DEBUG: Email length: ${widget.email.length}');
      print('DEBUG: OTP length: ${_otpController.text.length}');
      
      // Use the Riverpod provider to verify OTP
      await ref.read(authProvider.notifier).verifyOTP(
        widget.email.trim().toLowerCase(), // Clean the email
        _otpController.text.trim(), // Clean the OTP
      );

      // Navigation will be handled by the auth state listener
    } catch (e) {
      print('DEBUG: OTP verification error: $e');
      _showError('OTP verification failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authProvider, (previous, current) async {
      if (current.status == AuthStatus.authenticated) {
        // Check if user has completed profile setup
        final userId = current.userId;
        if (userId != null) {
          try {
            final response = await ApiService.checkProfileExists(userId.toString());
            final profileExists = response['profileExists'] ?? false;
            if (profileExists) {
              // Profile exists, go to home
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Welcome back to Assistrend!')),
              );
              context.go('/home');
            } else {
              // Profile doesn't exist, go to profile setup
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please complete your profile setup')),
              );
              context.go('/profile-setup');
            }
          } catch (e) {
            // Error checking profile, go to profile setup to be safe
            context.go('/profile-setup');
          }
        } else {
          // No user ID, go to profile setup
          context.go('/profile-setup');
        }
      } else if (current.status == AuthStatus.error && current.errorMessage != null) {
        _showError(current.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Verify OTP'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('login');// Go back
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                'Enter OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Please enter the verification code sent to ${widget.email}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 40, 108, 224),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Resend OTP implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('OTP resent to ${widget.email}')),
                  );
                },
                child: Text(
                  "Didn't receive the code? Resend",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Debug test button - remove this after testing
              if (true) // Change to false to hide this button
                ElevatedButton(
                  onPressed: () async {
                    // Test with hardcoded values
                    try {
                      print('DEBUG: Testing with hardcoded values');
                      final testResponse = await ApiService.verifyOTP(
                        widget.email.trim().toLowerCase(), 
                        '123456'  // Test OTP
                      );
                      print('DEBUG: Test response: $testResponse');
                      _showError('Test call successful - check console');
                    } catch (e) {
                      print('DEBUG: Test error: $e');
                      _showError('Test error: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                  ),
                  child: Text('DEBUG TEST', style: TextStyle(color: Colors.white)),
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

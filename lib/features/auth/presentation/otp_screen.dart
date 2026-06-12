import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/utils/storage.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String email;

  const OTPScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _remainingAttempts = 5;
  bool _otpExpired = false;

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
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

    if (!RegExp(r'^\d{6}$').hasMatch(_otpController.text)) {
      _showError('OTP must be exactly 6 digits');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: Verifying OTP for email: ${widget.email}');
      print('DEBUG: OTP code: ${_otpController.text}');
      
      // Verify OTP via API
      final response = await ApiService.verifyEmailOTP(
        widget.email.trim().toLowerCase(),
        _otpController.text.trim(),
      );

      if (response['success'] == true) {
        final authResponse = await ApiService.oauthCallback(
          widget.email.trim().toLowerCase(),
        );
        if (authResponse['success'] != true) {
          throw Exception(authResponse['error'] ?? 'Post-OTP authentication failed');
        }

        final accessToken = authResponse['access']?.toString();
        final refreshToken = authResponse['refresh']?.toString();
        final userId = authResponse['userId']?.toString();
        final userObj = authResponse['user'] as Map<String, dynamic>?;
        final isProfileComplete = userObj?['is_profile_complete'] == true;

        if (accessToken == null || refreshToken == null || userId == null) {
          throw Exception('Authentication tokens missing after OTP verification');
        }

        await Storage.saveToken(accessToken);
        await Storage.saveRefreshToken(refreshToken);
        await Storage.saveUserId(userId);
        await Storage.saveProfileComplete(isProfileComplete);

        _showSuccess('Email verified successfully!');

        if (mounted) {
          await Future.delayed(Duration(milliseconds: 500));
          context.go(isProfileComplete ? '/home' : '/profile-setup');
        }
      } else {
        final error = response['error'] ?? 'OTP verification failed';
        final remainingAttempts = response['remaining_attempts'];
        
        if (remainingAttempts != null) {
          setState(() {
            _remainingAttempts = remainingAttempts;
            if (_remainingAttempts <= 0) {
              _otpExpired = true;
            }
          });
          _showError('$error. Remaining attempts: $_remainingAttempts');
        } else {
          _showError(error);
        }
      }
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

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.resendEmailOTP(widget.email);
      
      if (response['success'] == true) {
        _showSuccess('OTP resent to ${widget.email}');
        setState(() {
          _otpExpired = false;
          _remainingAttempts = 5;
          _otpController.clear();
        });
      } else {
        _showError(response['error'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      print('DEBUG: Resend OTP error: $e');
      _showError('Failed to resend OTP: $e');
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Verify Email'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/login');
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
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 48,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Verify Your Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We sent a verification code to',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              
              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enabled: !_isLoading && !_otpExpired,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  letterSpacing: 12,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 12),
              
              // Remaining attempts indicator
              if (_remainingAttempts > 0 && _remainingAttempts < 5)
                Text(
                  'Remaining attempts: $_remainingAttempts',
                  style: TextStyle(
                    color: _remainingAttempts <= 2 ? Colors.orange : Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              
              SizedBox(height: 24),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _otpExpired) ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    disabledBackgroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOTP,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Expiry message
              if (_otpExpired)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'OTP expired. Please request a new one.',
                      style: TextStyle(
                        color: Colors.red[100],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}

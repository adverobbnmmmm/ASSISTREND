import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/signup_state.dart';
import '../providers/signup_provider.dart';
import 'signup_step1.dart';
import 'signup_step2.dart';
import 'signup_step3.dart';
import 'signup_step4.dart';
import 'signup_step5.dart';

class MultiStepSignUp extends ConsumerStatefulWidget {
  @override
  _MultiStepSignUpState createState() => _MultiStepSignUpState();
}

class _MultiStepSignUpState extends ConsumerState<MultiStepSignUp> {
  int _currentStep = 0;
  final List<String> _steps = ['Email', 'Password', 'Personal Info', 'Phone', 'Privacy'];

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text('Step ${_currentStep + 1} of ${_steps.length}'),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _steps[_currentStep],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _steps.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildCurrentStep(),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: Text('Back'),
                  ),
                if (_currentStep == 0)
                  SizedBox(width: 0),
                ElevatedButton(
                  onPressed: signupState.isLoading ? null : () => _handleNext(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: signupState.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentStep == _steps.length - 1 ? 'Complete' : 'Next',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return SignupStep1(onNext: _handleNext);
      case 1:
        return SignupStep2(onNext: _handleNext);
      case 2:
        return SignupStep3(onNext: _handleNext);
      case 3:
        return SignupStep4(onNext: _handleNext);
      case 4:
        return SignupStep5(onNext: _handleNext);
      default:
        return SizedBox();
    }
  }

  Future<void> _handleNext() async {
    final signupNotifier = ref.read(signupProvider.notifier);

    try {
      switch (_currentStep) {
        case 0:
          // Step 1: Email and Username
          if (!_validateStep1()) return;
          await signupNotifier.submitStep1();
          break;
        case 1:
          // Step 2: Password
          if (!_validateStep2()) return;
          await signupNotifier.submitStep2();
          break;
        case 2:
          // Step 3: Personal Info
          if (!_validateStep3()) return;
          await signupNotifier.submitStep3();
          break;
        case 3:
          // Step 4: Phone Number
          if (!_validateStep4()) return;
          await signupNotifier.submitStep4();
          break;
        case 4:
          // Step 5: Complete signup
          if (!_validateStep5()) return;
          await signupNotifier.submitStep5();
          await signupNotifier.completeSignup();
          
          // Navigate to OTP verification
          if (mounted) {
            final signupState = ref.read(signupProvider);
            context.push('/otp-verification?email=${Uri.encodeComponent(signupState.email)}');
          }
          return;
      }

      // Move to next step if successful
      if (mounted && _currentStep < 4) {
        setState(() {
          _currentStep++;
        });
      }
    } on SessionExpiredException catch (e) {
      // Handle session expiry
      if (mounted) {
        _showSessionExpiredDialog(e.message);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showSessionExpiredDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Session Expired',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Refresh session and go back to step 1
                ref.read(signupProvider.notifier).refreshSession();
                setState(() {
                  _currentStep = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Start Again'),
            ),
          ],
        );
      },
    );
  }

  bool _validateStep1() {
    final state = ref.read(signupProvider);
    if (state.email.isEmpty) {
      _showError('Email is required');
      return false;
    }
    if (state.username.isEmpty) {
      _showError('Username is required');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final state = ref.read(signupProvider);
    if (state.password.isEmpty) {
      _showError('Password is required');
      return false;
    }
    if (state.confirmPassword.isEmpty) {
      _showError('Confirm password is required');
      return false;
    }
    if (state.password != state.confirmPassword) {
      _showError('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    final state = ref.read(signupProvider);
    if (state.gender.isEmpty) {
      _showError('Please select a gender');
      return false;
    }
    if (state.dateOfBirth.isEmpty) {
      _showError('Please select your date of birth');
      return false;
    }
    return true;
  }

  bool _validateStep4() {
    final state = ref.read(signupProvider);
    if (state.phoneNumber.isEmpty) {
      _showError('Phone number is required');
      return false;
    }
    return true;
  }

  bool _validateStep5() {
    final state = ref.read(signupProvider);
    if (!state.privacyPolicyAccepted) {
      _showError('Please accept the privacy policy');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

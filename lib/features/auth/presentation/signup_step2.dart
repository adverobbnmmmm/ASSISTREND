import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';

class SignupStep2 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignupStep2({required this.onNext});

  @override
  _SignupStep2State createState() => _SignupStep2State();
}

class _SignupStep2State extends ConsumerState<SignupStep2> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupProvider);
    _passwordController = TextEditingController(text: state.password);
    _confirmPasswordController = TextEditingController(text: state.confirmPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _hasUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);
  bool _hasLowercase(String password) => RegExp(r'[a-z]').hasMatch(password);
  bool _hasNumber(String password) => RegExp(r'[0-9]').hasMatch(password);
  bool _hasSpecialChar(String password) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  bool _isLengthValid(String password) => password.length >= 8;
  bool _passwordsMatch() =>
      _passwordController.text == _confirmPasswordController.text &&
      _passwordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a strong password',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        SizedBox(height: 30),
        // Password field
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          onChanged: (value) {
            ref.read(signupProvider.notifier).updatePassword(value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
        // Confirm password field
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          onChanged: (value) {
            ref.read(signupProvider.notifier).updateConfirmPassword(value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordsMatch()
                    ? Colors.green
                    : (_confirmPasswordController.text.isNotEmpty
                        ? Colors.red
                        : Colors.grey[800]!),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordsMatch()
                    ? Colors.green
                    : (_confirmPasswordController.text.isNotEmpty
                        ? Colors.red
                        : Colors.blue),
              ),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 30),
        // Password requirements
        Text(
          'Password Requirements:',
          style: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 12),
        _PasswordRequirement(
          label: 'At least 8 characters',
          met: _isLengthValid(_passwordController.text),
        ),
        _PasswordRequirement(
          label: 'One uppercase letter (A-Z)',
          met: _hasUppercase(_passwordController.text),
        ),
        _PasswordRequirement(
          label: 'One lowercase letter (a-z)',
          met: _hasLowercase(_passwordController.text),
        ),
        _PasswordRequirement(
          label: 'One number (0-9)',
          met: _hasNumber(_passwordController.text),
        ),
        _PasswordRequirement(
          label: 'One special character (!@#\$%^&*)',
          met: _hasSpecialChar(_passwordController.text),
        ),
        _PasswordRequirement(
          label: 'Passwords match',
          met: _passwordsMatch(),
        ),
      ],
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String label;
  final bool met;

  const _PasswordRequirement({
    required this.label,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            color: met ? Colors.green : Colors.grey[600],
            size: 18,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: met ? Colors.green : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

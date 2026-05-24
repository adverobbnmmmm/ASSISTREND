import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';

class SignupStep1 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignupStep1({required this.onNext});

  @override
  _SignupStep1State createState() => _SignupStep1State();
}

class _SignupStep1State extends ConsumerState<SignupStep1> {
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  String? _emailError;
  String? _usernameError;
  bool _emailAvailable = true;
  bool _usernameAvailable = true;
  bool _checkingEmail = false;
  bool _checkingUsername = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupProvider);
    _emailController = TextEditingController(text: state.email);
    _usernameController = TextEditingController(text: state.username);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _validateEmail(String email) async {
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
        _emailAvailable = false;
      });
      return;
    }

    // Proper email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
        _emailAvailable = false;
      });
      return;
    }

    setState(() {
      _checkingEmail = true;
      _emailError = null;
    });

    try {
      final isAvailable = await ref.read(signupProvider.notifier).validateEmail(email);
      setState(() {
        _emailAvailable = isAvailable;
        _emailError = isAvailable ? null : 'Email already registered';
        _checkingEmail = false;
      });
    } catch (e) {
      setState(() {
        _emailError = 'Error checking email availability';
        _emailAvailable = false;
        _checkingEmail = false;
      });
    }
  }

  Future<void> _validateUsername(String username) async {
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username is required';
        _usernameAvailable = false;
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
        _usernameAvailable = false;
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _usernameError = 'Username can only contain letters, numbers, and underscores';
        _usernameAvailable = false;
      });
      return;
    }

    setState(() {
      _checkingUsername = true;
      _usernameError = null;
    });

    try {
      final isAvailable = await ref.read(signupProvider.notifier).validateUsername(username);
      setState(() {
        _usernameAvailable = isAvailable;
        _usernameError = isAvailable ? null : 'Username already taken';
        _checkingUsername = false;
      });
    } catch (e) {
      setState(() {
        _usernameError = 'Error checking username availability';
        _usernameAvailable = false;
        _checkingUsername = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        SizedBox(height: 30),
        // Email field
        TextField(
          controller: _emailController,
          onChanged: (value) {
            ref.read(signupProvider.notifier).updateEmail(value);
          },
          onEditingComplete: () => _validateEmail(_emailController.text),
          decoration: InputDecoration(
            hintText: 'Email address',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
            suffixIcon: _checkingEmail
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _emailAvailable && _emailController.text.isNotEmpty
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null ? Colors.red : Colors.grey[800]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null ? Colors.red : Colors.blue,
              ),
            ),
            errorText: _emailError,
            filled: true,
            fillColor: Colors.grey[900],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
        // Username field
        TextField(
          controller: _usernameController,
          onChanged: (value) {
            ref.read(signupProvider.notifier).updateUsername(value);
          },
          onEditingComplete: () => _validateUsername(_usernameController.text),
          decoration: InputDecoration(
            hintText: 'Username',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
            suffixIcon: _checkingUsername
                ? Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _usernameAvailable && _usernameController.text.isNotEmpty
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _usernameError != null ? Colors.red : Colors.grey[800]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _usernameError != null ? Colors.red : Colors.blue,
              ),
            ),
            errorText: _usernameError,
            filled: true,
            fillColor: Colors.grey[900],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
        Text(
          'Requirements:',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 8),
        _RequirementCheck(
          text: 'Valid email address',
          met: _emailAvailable && _emailController.text.isNotEmpty,
        ),
        _RequirementCheck(
          text: 'Username: 3+ characters, letters/numbers/_',
          met: _usernameAvailable &&
              _usernameController.text.isNotEmpty &&
              _usernameController.text.length >= 3,
        ),
      ],
    );
  }
}

class _RequirementCheck extends StatelessWidget {
  final String text;
  final bool met;

  const _RequirementCheck({
    required this.text,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            color: met ? Colors.green : Colors.grey[600],
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.green : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'assistrend_login.dart'; // Import the login page if needed
import 'services/api_service.dart';
import 'utils/storage.dart';
import 'screens/otp_screen.dart';

class AssistrendSignUp extends StatefulWidget {
  @override
  _AssistrendSignUpState createState() => _AssistrendSignUpState();
}

class _AssistrendSignUpState extends State<AssistrendSignUp> {
  bool isRememberMeChecked = false;
  bool _privacyPolicyAccepted = false; 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.register(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
        _privacyPolicyAccepted,  // Ensure this is a boolean value
      );
      
      // Handle successful registration
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(email: _emailController.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 64),
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
              SizedBox(height: 30),
              Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
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
                controller: _phoneController,  // ✅ Added phone input field
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
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _privacyPolicyAccepted,  // ✅ Privacy policy checkbox
                    onChanged: (bool? newValue) {
                      setState(() {
                        _privacyPolicyAccepted = newValue ?? false;
                      });
                    },
                    activeColor: Colors.blueAccent,
                    checkColor: Colors.white,
                  ),
                  Text(
                    'Accept Privacy Policy',
                    style: TextStyle(color: Colors.white),
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
                child: _isLoading
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

              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/google');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/google_logo.png', // Add Google logo in your assets folder
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Sign Up with Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )


            ],
          ),
        ),
      ),
    );
  }
}
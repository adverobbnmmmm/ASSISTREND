import 'package:flutter/material.dart';
import 'event_guidelines_page.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: 'Welcome User, to the\nnetworking '),
                    TextSpan(
                      text: '"arena"',
                      style: TextStyle(color: Color(0xFF2972FF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 180,
                child: Image(
                  image: AssetImage('assets/networking_illustration.png'),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2972FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventGuidelinesPage()),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
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

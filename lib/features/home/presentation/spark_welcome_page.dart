import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_guidelines_page.dart';

class SparkWelcomePage extends StatefulWidget {
  const SparkWelcomePage({Key? key}) : super(key: key);

  @override
  State<SparkWelcomePage> createState() => _SparkWelcomePageState();
}

class _SparkWelcomePageState extends State<SparkWelcomePage> {
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name')?.trim();
    if (!mounted) return;
    setState(() {
      _displayName = (name == null || name.isEmpty) ? 'User' : name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101318), Color(0xFF161B22), Color(0xFF0F1217)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 22),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22,
                      height: 1.15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: 'Welcome $_displayName, to the\nnetworking '),
                      const TextSpan(
                        text: '"arena"',
                        style: TextStyle(color: Color(0xFF0A69FF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Image.asset(
                      'assets/networking_illustration.png',
                      fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 236,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D5EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventGuidelinesPage(displayName: _displayName),
                        ),
                      );
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assistrend/features/profile/providers/profile_providers.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:assistrend/core/network/api_service.dart';
import 'event_guidelines_page.dart';
import 'apply_champion_page.dart';
import 'champion_hub_page.dart';

class SparkWelcomePage extends ConsumerStatefulWidget {
  const SparkWelcomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<SparkWelcomePage> createState() => _SparkWelcomePageState();
}

class _SparkWelcomePageState extends ConsumerState<SparkWelcomePage> {
  String _displayName = 'User';
  String _applicationStatus = 'none';
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
    _checkChampionApplicationStatus();
  }

  Future<void> _loadDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name')?.trim();
    if (!mounted) return;
    setState(() {
      _displayName = (name == null || name.isEmpty) ? 'User' : name;
    });
  }

  Future<void> _checkChampionApplicationStatus() async {
    if (!mounted) return;
    setState(() {
      _checkingStatus = true;
    });

    try {
      final statusRes = await ApiService.getChampionStatus();
      if (mounted) {
        setState(() {
          _applicationStatus = statusRes['application_status'] ?? 'none';
          _checkingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    
    // Proactively fetch profile if we have a userId but status is initial
    if (userId != null && ref.read(profileProvider).status == ProfileStatus.initial) {
      Future.microtask(() {
        ref.read(profileProvider.notifier).fetchProfile(userId);
      });
    }

    final profile = ref.watch(profileProvider).profile;
    final isChampion = profile.isCommunityChampion;

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
                      TextSpan(text: isChampion ? 'Welcome back $_displayName, to ' : 'Welcome $_displayName, to the\nnetworking '),
                      TextSpan(
                        text: isChampion ? 'Champion Hub' : '"arena"',
                        style: const TextStyle(color: Color(0xFF0A69FF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isChampion) ...[
                          // Glowing Badge
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D5EFF).withOpacity(0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1D5EFF).withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.shield, color: Color(0xFF1D5EFF), size: 80),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'You are a Community Champion!',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect with members under your specialized domains and offer support.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Image.asset(
                              'assets/networking_illustration.png',
                              fit: BoxFit.contain,
                              height: 180,
                            ),
                          ),
                          if (_checkingStatus)
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1D5EFF)),
                              ),
                            )
                          else if (_applicationStatus == 'pending')
                            Card(
                              color: const Color(0xFF21262D),
                              margin: const EdgeInsets.only(top: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.amber, width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.hourglass_empty, color: Colors.amber, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Application Pending',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Our admin team is currently reviewing your Community Champion application.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_applicationStatus == 'rejected')
                            Card(
                              color: const Color(0xFF21262D),
                              margin: const EdgeInsets.only(top: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.redAccent, width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Application Rejected',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your application was not approved. You can update your selection and re-apply.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ],
                    ),
                  ),
                ),
                if (isChampion) ...[
                  // Champion Buttons
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
                            builder: (_) => const ChampionHubPage(),
                          ),
                        ).then((_) => _checkChampionApplicationStatus());
                      },
                      child: const Text(
                        'Enter Champion Hub',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventGuidelinesPage(displayName: _displayName),
                        ),
                      );
                    },
                    child: Text(
                      'Connect as standard member',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ] else ...[
                  // Standard User Buttons
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
                  if (!_checkingStatus && _applicationStatus != 'pending')
                    SizedBox(
                      width: 236,
                      height: 54,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white30, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplyChampionPage(),
                            ),
                          ).then((_) => _checkChampionApplicationStatus());
                        },
                        child: const Text(
                          'Become a Champion',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

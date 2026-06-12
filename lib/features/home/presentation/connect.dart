import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/profile/providers/profile_providers.dart';
import 'package:assistrend/features/profile/models/profile_model.dart';
import 'package:assistrend/features/profile/presentation/edit_profile.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'chat_page.dart';
import 'spark_welcome_page.dart';

class ConnectButton extends ConsumerStatefulWidget {
  const ConnectButton({super.key});

  @override
  ConsumerState<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends ConsumerState<ConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  late Animation rotationAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _showStaticPage(BuildContext context, String title) {
    Widget page;
    if (title == 'Arena') {
      page = const ArenaPage();
    } else {
      page = const SparkWelcomePage();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  void _showIncompleteProfileDialog(BuildContext context, double completion, ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white12, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'Profile Incomplete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To access Connect features (Arena & Spark), your profile must be at least 40% complete.',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completion,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Completeness: ${(completion * 100).toInt()}% / 40%',
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage(profile: profile)),
              );
            },
            child: const Text('Complete Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    
    // Fetch profile if not loaded yet
    if (userId != null && ref.read(profileProvider).status == ProfileStatus.initial) {
      Future.microtask(() {
        ref.read(profileProvider.notifier).fetchProfile(userId);
      });
    }

    final profile = ref.watch(profileProvider).profile;
    
    // Calculate profile completion percentage
    double completion = 0.0;
    if (profile.name.isNotEmpty) completion += 0.20;
    if (profile.username.isNotEmpty) completion += 0.20;
    if (profile.emoji.isNotEmpty) completion += 0.10;
    if (profile.about.isNotEmpty) completion += 0.20;
    if (profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty) completion += 0.15;
    if (profile.audioUrl != null && profile.audioUrl!.isNotEmpty) completion += 0.10;
    if (profile.interests.isNotEmpty) completion += 0.05;

    final isProfileCompleteEnough = completion >= 0.40;

    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: <Widget>[
          Positioned(
              right: 15,
              bottom: 10,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  IgnorePointer(
                    child: Container(
                      color: Colors.transparent,
                      height: 150.0,
                      width: 150.0,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(270),
                        degOneTranslationAnimation.value * 100),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: Colors.white,
                        width: 70,
                        height: 70,
                        text: 'Spark',
                        onClick: () {
                          _showStaticPage(context, 'Spark');
                        },
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(180),
                        degThreeTranslationAnimation.value * 100),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degThreeTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: CircularButton(
                        color: Colors.white,
                        width: 70,
                        height: 70,
                        text: 'Arena',
                        onClick: () {
                          _showStaticPage(context, 'Arena');
                        },
                      ),
                    ),
                  ),
                  Transform(
                    transform: Matrix4.rotationZ(
                        getRadiansFromDegree(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: CircularButton(
                      color: Colors.blue,
                      width: 80,
                      height: 80,
                      text: 'Connect',
                      onClick: () {
                        if (!isProfileCompleteEnough) {
                          _showIncompleteProfileDialog(context, completion, profile);
                          return;
                        }
                        if (animationController.isCompleted) {
                          animationController.reverse();
                        } else {
                          animationController.forward();
                        }
                      },
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final String text;
  final VoidCallback onClick;

  const CircularButton(
      {super.key,
      this.color,
      this.width,
      this.height,
      required this.onClick,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(
          icon: Text(text,
              style: text != 'Connect'
                  ? const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)
                  : const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
          enableFeedback: true,
          onPressed: onClick),
    );
  }
}

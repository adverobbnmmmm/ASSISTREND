import 'package:flutter/material.dart';
import 'spark_conditions_page.dart';
import 'spark_flow_header.dart';

class EventGuidelinesPage extends StatelessWidget {
  final String displayName;

  const EventGuidelinesPage({Key? key, this.displayName = 'User'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12161C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SparkFlowHeader(stage: SparkFlowStage.guidelines),
              const SizedBox(height: 6),
              const Text(
                'Guidelines',
                style: TextStyle(
                  fontSize: 42,
                  color: Color(0xFF0A59FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: SingleChildScrollView(
                  child: _GuidelinesCopy(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 122,
                  height: 58,
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
                          builder: (_) => SparkConditionsPage(displayName: displayName),
                        ),
                      );
                    },
                    child: const Text(
                      'Ok',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidelinesCopy extends StatelessWidget {
  const _GuidelinesCopy();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 17,
      color: Colors.white.withOpacity(0.98),
      height: 1.45,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '" Networking is crucial for expanding opportunities,\n'
          'accessing valuable information, and building supportive\n'
          'relationships for personal and professional growth!"',
          style: bodyStyle,
        ),
        const SizedBox(height: 14),
        _BulletLine(
          icon: Icons.rocket_launch_outlined,
          text: 'Here, we aim to enhance the potential of networking.',
          style: bodyStyle,
        ),
        const SizedBox(height: 8),
        _BulletLine(
          icon: Icons.push_pin_outlined,
          text:
              'It is your secret weapon to unlock amazing opportunities,\nfind cool jobs, and build a strong support system in this\nvibrant world.',
          style: bodyStyle,
        ),
        const SizedBox(height: 14),
        Text(
          'With your daily life AI companion, Assistrend, you can\n'
          'explore the world! Are you ready to begin? Click OK.',
          style: bodyStyle,
        ),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextStyle style;

  const _BulletLine({
    required this.icon,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(icon, size: 16, color: const Color(0xFFFFFFFF)),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/signup_provider.dart';

class SignupStep5 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignupStep5({required this.onNext});

  @override
  _SignupStep5State createState() => _SignupStep5State();
}

class _SignupStep5State extends ConsumerState<SignupStep5> {
  bool _privacyAccepted = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupProvider);
    _privacyAccepted = state.privacyPolicyAccepted;
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review agreements',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        SizedBox(height: 30),
        // Privacy Policy Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[900],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'We respect your privacy and are committed to protecting your personal data. '
                'Our Privacy Policy explains how we collect, use, and protect your information. '
                'We only use your data to improve your experience and provide our services.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _launchURL('https://assistrend.com/privacy-policy'),
                child: Text(
                  'Read Full Privacy Policy →',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        // Terms of Service Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[900],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'By using Assistrend, you agree to our Terms of Service. '
                'You agree to use the platform responsibly and not engage in any harmful activities. '
                'You are responsible for maintaining the confidentiality of your account.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _launchURL('https://assistrend.com/terms-of-service'),
                child: Text(
                  'Read Full Terms of Service →',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        // Acceptance Checkboxes
        _AcceptanceCheckbox(
          label: 'I accept the Privacy Policy',
          value: _privacyAccepted,
          onChanged: (value) {
            setState(() {
              _privacyAccepted = value ?? false;
            });
            ref
                .read(signupProvider.notifier)
                .updatePrivacyPolicyAccepted(value ?? false);
          },
        ),
        SizedBox(height: 16),
        _AcceptanceCheckbox(
          label: 'I accept the Terms of Service',
          value: _termsAccepted,
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
        ),
        SizedBox(height: 24),
        // Info box
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: Colors.amber, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You must accept both the Privacy Policy and Terms of Service to create your account.',
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AcceptanceCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _AcceptanceCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? Colors.blue : Colors.grey[800]!,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: value ? Colors.blue.withOpacity(0.1) : Colors.grey[900],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: value ? Colors.blue : Colors.grey[700]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
                color: value ? Colors.blue : Colors.transparent,
              ),
              child: value
                  ? Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value ? Colors.blue : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';

class SignupStep4 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignupStep4({required this.onNext});

  @override
  _SignupStep4State createState() => _SignupStep4State();
}

class _SignupStep4State extends ConsumerState<SignupStep4> {
  late TextEditingController _phoneController;
  String? _phoneError;
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupProvider);
    _phoneController = TextEditingController(text: state.phoneNumber);
    _validatePhone(_phoneController.text);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Phone number is required';
        _isValidPhone = false;
      });
      return;
    }

    if (digitsOnly.length < 10) {
      setState(() {
        _phoneError = 'Phone number must have at least 10 digits';
        _isValidPhone = false;
      });
      return;
    }

    if (digitsOnly.length > 15) {
      setState(() {
        _phoneError = 'Phone number is too long';
        _isValidPhone = false;
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isValidPhone = true;
    });
  }

  String _formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) return '';
    if (digitsOnly.length <= 3) return digitsOnly;
    if (digitsOnly.length <= 6) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    }

    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your phone number?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        SizedBox(height: 30),
        // Country code selector
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[900],
          ),
          child: DropdownButton<String>(
            value: '+1',
            isExpanded: true,
            underline: SizedBox(),
            dropdownColor: Colors.grey[900],
            items: [
              DropdownMenuItem(
                value: '+1',
                child: Text('+1 (USA/Canada)', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: '+44',
                child: Text('+44 (UK)', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: '+91',
                child: Text('+91 (India)', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: '+61',
                child: Text('+61 (Australia)', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: '+86',
                child: Text('+86 (China)', style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (value) {},
          ),
        ),
        SizedBox(height: 20),
        // Phone number field
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            final formatted = _formatPhoneNumber(value);
            if (formatted != value) {
              _phoneController.value = _phoneController.value.copyWith(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
            _validatePhone(value);
            ref.read(signupProvider.notifier).updatePhoneNumber(value);
          },
          decoration: InputDecoration(
            hintText: 'Phone number',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.phone, color: Colors.grey[600]),
            suffixIcon: _isValidPhone && _phoneController.text.isNotEmpty
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _phoneError != null ? Colors.red : Colors.grey[800]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _phoneError != null ? Colors.red : Colors.blue,
              ),
            ),
            errorText: _phoneError,
            filled: true,
            fillColor: Colors.grey[900],
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
        // Info about phone number
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'We\'ll use this number to verify your account and help you recover it if needed.',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        // Phone format examples
        Text(
          'Accepted formats:',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 8),
        _FormatExample(format: '+1 (555) 123-4567'),
        _FormatExample(format: '555-123-4567'),
        _FormatExample(format: '5551234567'),
      ],
    );
  }
}

class _FormatExample extends StatelessWidget {
  final String format;

  const _FormatExample({required this.format});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(
            format,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

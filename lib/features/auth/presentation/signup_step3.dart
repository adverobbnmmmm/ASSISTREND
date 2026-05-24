import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';

class SignupStep3 extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const SignupStep3({required this.onNext});

  @override
  _SignupStep3State createState() => _SignupStep3State();
}

class _SignupStep3State extends ConsumerState<SignupStep3> {
  late TextEditingController _dobController;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(signupProvider);
    _dobController = TextEditingController(text: state.dateOfBirth);
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dobController.text = formattedDate;
      ref.read(signupProvider.notifier).updateDateOfBirth(formattedDate);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupProvider);
    final selectedGender = state.gender.isEmpty ? null : state.gender;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about yourself',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        SizedBox(height: 30),
        // Gender selector
        Text(
          'Gender',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _genderOptions.map((gender) {
            final isSelected = selectedGender == gender.toLowerCase();
            return GestureDetector(
              onTap: () {
                ref.read(signupProvider.notifier).updateGender(gender.toLowerCase());
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[700]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[900],
                ),
                child: Text(
                  gender,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 30),
        // Date of birth field
        Text(
          'Date of Birth',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _dobController,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
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
        // Age verification info
        if (_dobController.text.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _calculateAge(_dobController.text),
                    style: TextStyle(
                      color: Colors.blue[300],
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

  String _calculateAge(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      final age = today.year - date.year - (today.month < date.month || (today.month == date.month && today.day < date.day) ? 1 : 0);
      
      if (age < 13) {
        return '⚠️ You must be at least 13 years old to create an account.';
      }
      return '✓ Age: $age years old';
    } catch (e) {
      return 'Invalid date format';
    }
  }
}

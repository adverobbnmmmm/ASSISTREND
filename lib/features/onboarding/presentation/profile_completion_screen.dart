import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/social_api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/providers/profile_providers.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  _ProfileCompletionScreenState createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  final TextEditingController _aboutController = TextEditingController();
  final List<String> _selectedInterests = [];
  final List<String> _availableInterests = [
    'Technology', 'Sports', 'Music', 'Art', 'Travel', 'Food', 'Books', 'Movies',
    'Gaming', 'Fashion', 'Fitness', 'Photography', 'Cooking', 'Dancing', 'Writing',
    'Science', 'Nature', 'Business', 'Education', 'Health', 'Politics', 'History',
    'Literature', 'Philosophy', 'Psychology', 'Medicine', 'Engineering', 'Design',
    'Marketing', 'Finance', 'Entrepreneurship', 'Volunteering', 'Pets', 'Gardening',
    'DIY', 'Crafts', 'Meditation', 'Yoga', 'Running', 'Cycling', 'Swimming',
    'Hiking', 'Camping', 'Fishing', 'Hunting', 'Skiing', 'Snowboarding'
  ];
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
  }

  Future<void> _checkExistingProfile() async {
    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        // User not authenticated, redirect to login
        if (mounted) {
          context.go('/login');
        }
        return;
      }

      // Try to fetch existing profile data
      await ref.read(profileProvider.notifier).fetchProfile(userId);
      final profileState = ref.read(profileProvider);
      
      if (profileState.status == ProfileStatus.loaded) {
        final profile = profileState.profile;
        
        // If profile already has interests and about, skip to home
        if (profile.interests.isNotEmpty && profile.about.isNotEmpty) {
          if (mounted) {
            context.go('/home');
          }
          return;
        }
        
        // Pre-fill existing data
        _aboutController.text = profile.about;
        _selectedInterests.addAll(profile.interests);
        
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // Continue with onboarding even if profile fetch fails
      print('Error checking existing profile: $e');
    }
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_selectedInterests.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one interest';
      });
      return;
    }

    if (_aboutController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please add something about yourself';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update about information
      await SocialApiService.updateAbout(userId, _aboutController.text.trim());
      
      // Update interests
      await SocialApiService.updateInterests(userId, _selectedInterests);

      // Refresh profile data
      await ref.read(profileProvider.notifier).fetchProfile(userId);
      
      // Update auth state to reflect profile completion
      await ref.read(authProvider.notifier).updateProfileCompletionStatus(userId);
      
      // Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              const Text(
                'Welcome to Assistrend! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s get to know you better. This helps us personalize your experience.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // About Section
              const Text(
                'About You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800, width: 1),
                ),
                child: TextField(
                  controller: _aboutController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Tell us about yourself, your goals, what you\'re passionate about...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Interests Section
              const Text(
                'Your Interests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select at least 1 interest (${_selectedInterests.length} selected)',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // Interests grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => _toggleInterest(interest),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.blue.withOpacity(0.2)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.white,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.go('/home'),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/utils/storage.dart';
import '../models/profile_setup_model.dart';
import '../providers/profile_setup_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final _emojiController = TextEditingController();
  
  String _selectedGender = '';
  DateTime? _selectedDate;
  String? _profileImageUrl;
  String? _audioUrl;
  List<String> _selectedInterests = [];
  List<String> _availableInterests = [];
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _commonInterests = [
    'Technology', 'Sports', 'Music', 'Movies', 'Books', 'Travel', 'Food', 
    'Art', 'Photography', 'Gaming', 'Fitness', 'Fashion', 'Science', 
    'Nature', 'Dancing', 'Cooking', 'Writing', 'Languages', 'History', 'Politics'
  ];

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    try {
      final response = await ApiService.getInterests();
      if (response['status'] == 'success') {
        setState(() {
          _availableInterests = List<String>.from(
            response['interests'].map((interest) => interest['interestName'])
          );
        });
      }
    } catch (e) {
      // Use common interests if API fails
      setState(() {
        _availableInterests = _commonInterests;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.grey[800]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null) {
        // In a real app, you would upload the file to a server
        // For now, we'll just store the path
        setState(() {
          _profileImageUrl = result.files.first.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null) {
        // Store the local path for now - in a full implementation,
        // you would upload this to Cloudinary and get the URL
        setState(() {
          _audioUrl = result.files.first.path;
        });
        
        // Optional: Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio file selected successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking audio: $e')),
      );
    }
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

  Future<void> _setupProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username is required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await Storage.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final profileData = ProfileSetupModel(
        userName: _userNameController.text,
        emoji: _emojiController.text,
        about: _aboutController.text,
        location: _locationController.text,
        dob: _selectedDate,
        gender: _selectedGender.isEmpty ? null : _selectedGender,
        profileImageUrl: _profileImageUrl,
        audioUrl: _audioUrl,
        interests: _selectedInterests,
      );

      await ref.read(profileSetupProvider.notifier).setupProfile(userId.toString(), profileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile setup completed successfully!')),
      );

      // Navigate to home screen
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting up profile: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _profileImageUrl != null 
                          ? NetworkImage(_profileImageUrl!) 
                          : null,
                      child: _profileImageUrl == null 
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Username Field
              _buildTextField(
                controller: _userNameController,
                label: 'Username *',
                hint: 'Enter your username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Emoji Field
              _buildTextField(
                controller: _emojiController,
                label: 'Emoji',
                hint: 'Choose an emoji that represents you',
              ),
              SizedBox(height: 20),

              // About Field
              _buildTextField(
                controller: _aboutController,
                label: 'About',
                hint: 'Tell us about yourself',
                maxLines: 3,
              ),
              SizedBox(height: 20),

              // Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Where are you from?',
              ),
              SizedBox(height: 20),

              // Date of Birth
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null 
                            ? 'Date of Birth' 
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null ? Colors.grey : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Gender Selection
              Text(
                'Gender',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                children: _genders.map((gender) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedGender == gender 
                                  ? Colors.blueAccent 
                                  : Colors.grey[600]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedGender == gender 
                                ? Colors.blueAccent.withOpacity(0.1) 
                                : Colors.transparent,
                          ),
                          child: Text(
                            gender,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedGender == gender 
                                  ? Colors.blueAccent 
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Audio Introduction
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Introduction',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    if (_audioUrl != null) ...[
                      Text(
                        'Audio file selected',
                        style: TextStyle(color: Colors.green),
                      ),
                      SizedBox(height: 10),
                    ],
                    ElevatedButton.icon(
                      onPressed: _pickAudioFile,
                      icon: Icon(Icons.mic),
                      label: Text(_audioUrl == null ? 'Add Audio' : 'Change Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Interests Selection
              Text(
                'Interests',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => _toggleInterest(interest),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.grey[600]!,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected 
                            ? Colors.blueAccent.withOpacity(0.1) 
                            : Colors.transparent,
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),

              // Setup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setupProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Setup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: Text(
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    _emojiController.dispose();
    super.dispose();
  }
}

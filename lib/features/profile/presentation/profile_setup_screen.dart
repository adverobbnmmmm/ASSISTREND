import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/utils/storage.dart';
import '../models/profile_setup_model.dart';
import '../providers/profile_setup_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final _emojiController = TextEditingController();
  final _highlightQuestionController = TextEditingController();
  
  String _selectedGender = '';
  DateTime? _selectedDate;
  String? _profileImageUrl;
  String? _audioUrl;
  final List<int> _selectedInterestIds = [];
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileSetupProvider.notifier).loadInterests();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
        setState(() {
          _audioUrl = result.files.first.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio file selected successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking audio: $e')),
      );
    }
  }

  Future<void> _setupProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is required')),
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
        highlightQuestion: _highlightQuestionController.text.trim(),
        interests: _selectedInterestIds,
      );

      await ref.read(profileSetupProvider.notifier).setupProfile(userId.toString(), profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile setup completed successfully!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting up profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
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
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

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
              const SizedBox(height: 20),

              // Emoji Field
              _buildTextField(
                controller: _emojiController,
                label: 'Emoji',
                hint: 'Choose an emoji that represents you',
              ),
              const SizedBox(height: 20),

              // About Field
              _buildTextField(
                controller: _aboutController,
                label: 'About',
                hint: 'Tell us about yourself',
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Where are you from?',
              ),
              const SizedBox(height: 20),

              // Highlight Question Field
              _buildTextField(
                controller: _highlightQuestionController,
                label: 'Highlight Question',
                hint: 'Type a question for others to answer...',
              ),
              const SizedBox(height: 20),

              // Date of Birth
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gender Selection
              const Text(
                'Gender',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: _genders.map((gender) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
              const SizedBox(height: 20),

              // Audio Introduction
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audio Introduction',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (_audioUrl != null) ...[
                      const Text(
                        'Audio file selected',
                        style: TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 10),
                    ],
                    ElevatedButton.icon(
                      onPressed: _pickAudioFile,
                      icon: const Icon(Icons.mic),
                      label: Text(_audioUrl == null ? 'Add Audio' : 'Change Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interests Selection (Spotify-style)
              _buildInterestsSection(setupState.interests),
              const SizedBox(height: 30),

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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Complete Setup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/home');
                  },
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

  Widget _buildInterestsSection(List<InterestCategory> categories) {
    if (categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Select categories to choose your sub-interests (Spotify-style)',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final selectedCount = category.subcategories
                .where((sub) => _selectedInterestIds.contains(sub.id))
                .length;

            return _buildCategoryCard(category, selectedCount);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(InterestCategory category, int selectedCount) {
    Gradient cardGradient;
    IconData categoryIcon;

    if (category.name.toLowerCase().contains('sport')) {
      cardGradient = const LinearGradient(
        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      categoryIcon = Icons.sports_soccer;
    } else if (category.name.toLowerCase().contains('music')) {
      cardGradient = const LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      categoryIcon = Icons.music_note;
    } else if (category.name.toLowerCase().contains('show') || category.name.toLowerCase().contains('movie')) {
      cardGradient = const LinearGradient(
        colors: [Color(0xFFED213A), Color(0xFF93291E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      categoryIcon = Icons.movie;
    } else if (category.name.toLowerCase().contains('tech') || category.name.toLowerCase().contains('code')) {
      cardGradient = const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      categoryIcon = Icons.computer;
    } else if (category.name.toLowerCase().contains('travel') || category.name.toLowerCase().contains('hike')) {
      cardGradient = const LinearGradient(
        colors: [Color(0xFFF12711), Color(0xFFF5AF19)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      categoryIcon = Icons.flight;
    } else {
      cardGradient = const LinearGradient(
        colors: [Color(0xFF373B44), Color(0xFF4286F4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      categoryIcon = Icons.interests;
    }

    return GestureDetector(
      onTap: () => _showSubcategoriesSheet(category),
      child: Container(
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                categoryIcon,
                size: 64,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedCount > 0
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedCount > 0
                        ? '$selectedCount selected'
                        : 'Explore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: selectedCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSubcategoriesSheet(InterestCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose related interests you like',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: category.subcategories.map((sub) {
                          final isSelected = _selectedInterestIds.contains(sub.id);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedInterestIds.remove(sub.id);
                                } else {
                                  _selectedInterestIds.add(sub.id);
                                }
                              });
                              setModalState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent.withOpacity(0.2)
                                    : const Color(0xFF282828),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check,
                                      color: Colors.blueAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    sub.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blueAccent
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
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
    _highlightQuestionController.dispose();
    super.dispose();
  }
}

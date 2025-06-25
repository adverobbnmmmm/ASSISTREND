import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/profile/models/profile_model.dart';
import 'package:assistrend/features/profile/providers/profile_providers.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:assistrend/core/network/social_api_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final ProfileModel profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController aboutController;
  late TextEditingController emojiController;
  List<String> interests = [];
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile data
    nameController = TextEditingController(text: widget.profile.name);
    aboutController = TextEditingController(text: widget.profile.about);
    emojiController = TextEditingController(text: widget.profile.emoji);
    interests = List.from(widget.profile.interests);
  }

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    emojiController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (nameController.text.trim().isEmpty) {
      _showErrorMessage('Name cannot be empty');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await SocialApiService.updateName(
        userId,
        nameController.text.trim(),
      );
      
      // Update the profile in the state
      await ref.read(profileProvider.notifier).updateProfile(
        userId,
        name: nameController.text.trim(),
      );

      setState(() {
        successMessage = 'Name updated successfully';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update name: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateAbout() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await SocialApiService.updateAbout(
        userId,
        aboutController.text.trim(),
      );
      
      // Update the profile in the state
      await ref.read(profileProvider.notifier).updateProfile(
        userId,
        about: aboutController.text.trim(),
      );

      setState(() {
        successMessage = 'About section updated successfully';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update about section: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateEmoji() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await SocialApiService.updateEmoji(
        userId,
        emojiController.text,
      );
      
      // Update the profile in the state
      await ref.read(profileProvider.notifier).updateProfile(
        userId,
        emoji: emojiController.text,
      );

      setState(() {
        successMessage = 'Emoji updated successfully';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update emoji: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateInterests() async {
    if (interests.isEmpty) {
      _showErrorMessage('Please add at least one interest');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await SocialApiService.updateInterests(
        userId,
        interests,
      );

      setState(() {
        successMessage = 'Interests updated successfully';
      });
      
      // Refresh profile data
      await ref.read(profileProvider.notifier).fetchProfile(userId);
      
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update interests: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addInterest(String interest) {
    if (interest.trim().isNotEmpty && !interests.contains(interest.trim())) {
      setState(() {
        interests.add(interest.trim());
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      interests.remove(interest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (successMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Text(
                        successMessage!,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  _buildProfilePhotoSection(),
                  const SizedBox(height: 24),
                  _buildNameSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildEmojiSection(),
                  const SizedBox(height: 24),
                  _buildInterestsSection(),
                  const SizedBox(height: 24),
                  _buildSocialsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                    "https://ui-avatars.com/api/?name=${widget.profile.name}&background=random"
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    onPressed: () {
                      // Implement photo picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile photo update not implemented yet')),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "@${widget.profile.username}",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Name'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Your name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: _updateName,
            child: Text('Update Name'),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: TextField(
            controller: aboutController,
            style: const TextStyle(color: Colors.white),
            maxLines: 5,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Write something about yourself...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: _updateAbout,
            child: Text('Update About'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Emoji'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800, width: 1),
                ),
                child: TextField(
                  controller: emojiController,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  maxLength: 2, // Most emojis are 1-2 code points
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '😊',
                    hintStyle: TextStyle(color: Colors.grey),
                    counterText: '', // Hide character counter
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _updateEmoji,
              child: Text('Update'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choose an emoji that represents you',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    final TextEditingController interestController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Interests'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800, width: 1),
                ),
                child: TextField(
                  controller: interestController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add an interest',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _addInterest(value);
                      interestController.clear();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.blue, size: 36),
              onPressed: () {
                if (interestController.text.trim().isNotEmpty) {
                  _addInterest(interestController.text);
                  interestController.clear();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: interests.map((interest) => _buildInterestChip(interest)).toList(),
        ),
        if (interests.isNotEmpty) const SizedBox(height: 16),
        if (interests.isNotEmpty)
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: _updateInterests,
              child: Text('Update Interests'),
            ),
          ),
      ],
    );
  }

  Widget _buildInterestChip(String interest) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, 10, 24, 10),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: Text(
            interest,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _removeInterest(interest),
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialsSection() {
    final platforms = ['Instagram', 'Twitter', 'LinkedIn', 'GitHub', 'YouTube'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Social Links'),
        const SizedBox(height: 16),
        ...platforms.map((platform) => _buildSocialField(platform)),
      ],
    );
  }

  Widget _buildSocialField(String platform) {
    final TextEditingController urlController = TextEditingController();
    // Find if this platform exists in the user's socials
    final socialLink = widget.profile.socials.firstWhere(
      (social) => social.platform.toLowerCase() == platform.toLowerCase(),
      orElse: () => SocialLink(
        platform: platform,
        url: '',
      ),
    );
    
    urlController.text = socialLink.url;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              platform,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800, width: 1),
              ),
              child: TextField(
                controller: urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter $platform URL',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (urlController.text.trim().isEmpty) return;
              
              try {
                final authState = ref.read(authProvider);
                final userId = authState.userId;
                
                if (userId == null) {
                  throw Exception('User not authenticated');
                }

                await SocialApiService.updateSocials(
                  userId,
                  platform,
                  urlController.text.trim(),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$platform link updated successfully')),
                );
                
                // Refresh profile data
                await ref.read(profileProvider.notifier).fetchProfile(userId);
                
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update $platform link: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
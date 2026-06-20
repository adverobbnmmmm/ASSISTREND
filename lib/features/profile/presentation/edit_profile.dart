import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/profile/models/profile_model.dart';
import 'package:assistrend/features/profile/providers/profile_providers.dart';
import 'package:assistrend/features/auth/providers/auth_provider.dart';
import 'package:assistrend/shared/utils/storage.dart';
import 'package:assistrend/core/network/social_api_service.dart';
import '../widgets/profile_audio_widget.dart';
import '../widgets/profile_photo_widget.dart';

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
  late TextEditingController highlightQuestionController;
  List<String> interests = [];
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  // Controllers for each social platform
  Map<String, TextEditingController> _socialControllers = {};
  final _socialPlatforms = ['Instagram', 'Twitter', 'LinkedIn', 'GitHub', 'YouTube'];

  // Track audio/photo URLs that were updated inline
  String? _pendingAudioUrl;
  bool _audioChanged = false;
  String? _pendingPhotoUrl;
  bool _photoChanged = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    aboutController = TextEditingController(text: widget.profile.about);
    emojiController = TextEditingController(text: widget.profile.emoji);
    highlightQuestionController = TextEditingController(text: widget.profile.highlightQuestion);
    interests = List.from(widget.profile.interests);

    // Pre-populate social controllers from existing profile data
    for (final platform in _socialPlatforms) {
      final socialLink = widget.profile.socials.firstWhere(
        (social) => social.platform.toLowerCase() == platform.toLowerCase(),
        orElse: () => SocialLink(platform: platform, url: ''),
      );
      _socialControllers[platform] = TextEditingController(text: socialLink.url);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    emojiController.dispose();
    highlightQuestionController.dispose();
    for (final c in _socialControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Single method that saves ALL edited fields in one go.
  Future<void> _saveAllChanges() async {
    // Read from Storage first (always available), fall back to authProvider.
    String? userId = await Storage.getUserId();
    if (userId == null) {
      userId = ref.read(authProvider).userId;
    }
    if (userId == null) {
      _showErrorMessage('User not authenticated');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      // 1. Update text fields via the profile API (single PATCH)
      await ref.read(profileProvider.notifier).updateProfile(
        userId,
        name: nameController.text.trim(),
        about: aboutController.text.trim(),
        emoji: emojiController.text.trim(),
        highlightQuestion: highlightQuestionController.text.trim(),
        profileImageUrl: _photoChanged ? _pendingPhotoUrl : null,
        audioUrl: _audioChanged ? _pendingAudioUrl : null,
        interests: interests.isNotEmpty
            ? interests.map((name) => name.hashCode).toList()
            : null,
      );

      // 2. Update interests via the social API (if changed)
      if (interests.isNotEmpty) {
        await SocialApiService.updateInterests(userId, interests);
      }

      // 3. Update each modified social link
      for (final platform in _socialPlatforms) {
        final controller = _socialControllers[platform];
        if (controller == null) continue;
        final newUrl = controller.text.trim();
        final existingLink = widget.profile.socials.firstWhere(
          (social) => social.platform.toLowerCase() == platform.toLowerCase(),
          orElse: () => SocialLink(platform: platform, url: ''),
        );
        final oldUrl = existingLink.url;
        // Only call the API if the URL actually changed or is new
        if (newUrl != oldUrl && newUrl.isNotEmpty) {
          await SocialApiService.updateSocials(userId, platform, newUrl);
        }
      }

      // 4. Refresh profile
      await ref.read(profileProvider.notifier).fetchProfile(userId);

      setState(() {
        successMessage = 'Profile updated successfully';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update profile: ${e.toString()}';
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

  void _onAudioUpdated(String? audioUrl) {
    setState(() {
      _pendingAudioUrl = audioUrl;
      _audioChanged = true;
    });
  }

  void _onPhotoUploaded(String? photoUrl) {
    setState(() {
      _pendingPhotoUrl = photoUrl;
      _photoChanged = true;
    });
  }

  Widget _buildGradientBorderButton(String text, VoidCallback onPressed, {bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: enabled
              ? [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                ]
              : List.filled(7, Colors.grey.shade700),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(200, 48),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
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
                        style: const TextStyle(color: Colors.red),
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
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  _buildProfilePhotoSection(),
                  const SizedBox(height: 24),
                  _buildNameSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildHighlightQuestionSection(),
                  const SizedBox(height: 24),
                  _buildAudioSection(),
                  const SizedBox(height: 24),
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  _buildEmojiSection(),
                  const SizedBox(height: 24),
                  _buildInterestsSection(),
                  const SizedBox(height: 24),
                  _buildSocialsSection(),
                  const SizedBox(height: 32),
                  // Single "Update Profile" button
                  Center(
                    child: _buildGradientBorderButton('Update Profile', _saveAllChanges),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePhotoSection() {
    final displayUrl = _photoChanged ? _pendingPhotoUrl : widget.profile.profileImageUrl;
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
                  backgroundImage: displayUrl != null && displayUrl.isNotEmpty
                      ? NetworkImage(displayUrl)
                      : NetworkImage(
                          "https://ui-avatars.com/api/?name=${widget.profile.name}&background=random",
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
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Use the Profile Photo section below to update')),
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
            color: const Color(0xFF1A1A1A),
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
            color: const Color(0xFF1A1A1A),
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
      ],
    );
  }

  Widget _buildHighlightQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Highlight Question'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: TextField(
            controller: highlightQuestionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Type a question for others to answer...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile Audio'),
        const SizedBox(height: 12),
        ProfileAudioWidget(
          currentAudioUrl: _audioChanged ? _pendingAudioUrl : widget.profile.audioUrl,
          onAudioUpdated: _onAudioUpdated,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile Photo'),
        const SizedBox(height: 12),
        ProfilePhotoWidget(
          currentProfileImageUrl: _photoChanged ? _pendingPhotoUrl : widget.profile.profileImageUrl,
          onPhotoUploaded: _onPhotoUploaded,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: TextField(
            controller: emojiController,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            maxLength: 2,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '😊',
              hintStyle: TextStyle(color: Colors.grey),
              counterText: '',
            ),
          ),
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
                  color: const Color(0xFF1A1A1A),
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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_circle, size: 36, color: Colors.white),
                  onPressed: () {
                    if (interestController.text.trim().isNotEmpty) {
                      _addInterest(interestController.text);
                      interestController.clear();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: interests.map((interest) => _buildInterestChip(interest)).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String interest) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: Text(
            interest,
            style: const TextStyle(
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
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Social Links'),
        const SizedBox(height: 16),
        ..._socialPlatforms.map((platform) => _buildSocialField(platform)),
      ],
    );
  }

  Widget _buildSocialField(String platform) {
    final controller = _socialControllers[platform]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              platform,
              style: const TextStyle(
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
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800, width: 1),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter $platform URL',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

  }
}
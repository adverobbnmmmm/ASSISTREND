import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/upload_provider.dart';
import '../services/permission_service.dart';
import '../widgets/media_preview_card.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}




class _UploadPageState extends ConsumerState<UploadPage> {
  late TextEditingController _captionController;
  final FocusNode _captionFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();

    // Reset upload state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _captionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Update controller if state changes externally
    if (_captionController.text != uploadState.caption) {
      _captionController.text = uploadState.caption;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(uploadState, theme),
      body: Builder(
        builder: (BuildContext context) {
          // Watch the provider here to react to state changes
          ref.watch(uploadProvider.select((state) => state.uploadSuccess));
          ref.watch(uploadProvider.select((state) => state.error));
          ref.watch(uploadProvider.select((state) => state.isRecording));
          ref.watch(uploadProvider.select((state) => state.showAudioPrompt));

          // Use a post-frame callback to show SnackBar only (navigation handled in button)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final uploadState = ref.read(uploadProvider);
            if (uploadState.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload failed: ${uploadState.error}')), 
              );
            }
          });

          // Show audio prompt dialog when needed (separate from post-frame callback)
          if (uploadState.showAudioPrompt) {
            print('DEBUG: showAudioPrompt is true, showing dialog');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showAudioPromptDialog();
            });
          } else {
            print('DEBUG: showAudioPrompt is false');
          }

          // Show recording UI if recording is active
          if (uploadState.isRecording) {
            return _buildRecordingView(uploadState);
          }

          return !uploadState.hasMedia
            ? _buildMediaSelectionView(context, uploadState) 
            : _buildPostCreationView(uploadState, context, screenWidth);
        },
      ),
    );
  }
  
  // Instagram-style app bar with context-aware title and action
  PreferredSizeWidget _buildAppBar(UploadState uploadState, ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(
        !uploadState.hasMedia ? 'New Post' : 'Edit Post',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          // If we have media and try to go back, confirm discard
          if (uploadState.hasMedia) {
            _showDiscardConfirmation();
          } else {
            // No media selected, safe to go back to home
            context.go('/home');
          }
        },
      ),
      actions: [
        
        if (uploadState.hasMedia)
          TextButton(
            onPressed: uploadState.isValid && !uploadState.isUploading
                ? () async {
                    try {
                      await ref.read(uploadProvider.notifier).handleUpload();
                      
                      // Check if upload was successful
                      final finalState = ref.read(uploadProvider);
                      if (finalState.uploadSuccess && context.mounted) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post uploaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        
                        // Clear the upload success state by resetting
                        ref.read(uploadProvider.notifier).reset();
                        
                        // Navigate to home using pushReplacement to avoid stack issues
                        context.pushReplacement('/home');
                      }
                    } catch (e) {
                      print("Upload failed: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Upload failed: $e')),
                        );
                      }
                    }
                  }
                : null,
            child: uploadState.isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  )
                : Text(
                    'Share',
                    style: TextStyle(
                      color: uploadState.isValid 
                          ? Colors.blue 
                          : Colors.blue.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
      ],
    );
  }
  
  // Audio recording view
  Widget _buildRecordingView(UploadState uploadState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording indicator
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: const Icon(
                Icons.mic,
                size: 80,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            
            // Recording status
            const Text(
              'Recording Audio...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            
            // Recording controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                ElevatedButton.icon(
                  onPressed: () => ref.read(uploadProvider.notifier).cancelAudioRecording(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                
                // Stop button
                ElevatedButton.icon(
                  onPressed: () => ref.read(uploadProvider.notifier).stopAudioRecording(),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Error message
            if (uploadState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  uploadState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Instagram-style media selection screen with large buttons
  Widget _buildMediaSelectionView(BuildContext context, UploadState uploadState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create New Post',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how you want to create your post',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Instagram-style media options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaSelectionCard(
                  title: 'Camera',
                  icon: Icons.camera_alt,
                  onTap: () async {
                    final hasPermission = await PermissionService.requestCameraPermission(context);
                    if (hasPermission && context.mounted) {
                      ref.read(uploadProvider.notifier).pickImage(fromCamera: true);
                    }
                  },
                ),
                _buildMediaSelectionCard(
                  title: 'Video',
                  icon: Icons.videocam,
                  onTap: () async {
                    final hasPermission = await PermissionService.requestCameraPermission(context);
                    if (hasPermission && context.mounted) {
                      ref.read(uploadProvider.notifier).pickVideo(fromCamera: true);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaSelectionCard(
                  title: 'Gallery',
                  icon: Icons.photo_library,
                  onTap: () async {
                    final hasPermission = await PermissionService.requestStoragePermission(context);
                    if (hasPermission && context.mounted) {
                      ref.read(uploadProvider.notifier).pickImage(fromCamera: false);
                    }
                  },
                ),
                _buildMediaSelectionCard(
                  title: 'Gallery Video',
                  icon: Icons.video_library,
                  onTap: () async {
                    final hasPermission = await PermissionService.requestStoragePermission(context);
                    if (hasPermission && context.mounted) {
                      ref.read(uploadProvider.notifier).pickVideo(fromCamera: false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaSelectionCard(
                  title: 'Record Audio',
                  icon: Icons.mic,
                  onTap: () async {
                    final hasPermission = await PermissionService.requestMicrophonePermission(context);
                    if (hasPermission && context.mounted) {
                      ref.read(uploadProvider.notifier).startAudioRecording();
                    }
                  },
                ),
                _buildMediaSelectionCard(
                  title: 'Audio File',
                  icon: Icons.audio_file,
                  onTap: () async {
                    final hasPermission = await PermissionService.requestStoragePermission(context);
                    if (hasPermission && context.mounted) {
                      ref.read(uploadProvider.notifier).pickAudio();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Error message
            if (uploadState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  uploadState.error!,
                  style: TextStyle(color: Colors.red.shade300),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Instagram-style media selection card
  Widget _buildMediaSelectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title, 
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Instagram-style post creation view with media preview and caption
  Widget _buildPostCreationView(UploadState uploadState, BuildContext context, double screenWidth) {
    return Column(
      children: [
        // Media preview (square like Instagram)
        if (uploadState.selectedMedia != null)
          AspectRatio(
            aspectRatio: 1.0,  // Square aspect ratio like Instagram
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: MediaPreviewCard(
                media: uploadState.selectedMedia!,
                onDelete: () => ref.read(uploadProvider.notifier).clearMedia(),
              ),
            ),
          ),
        
        const Divider(height: 1),
        
        // Caption and options section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Category selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: uploadState.category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Select a category'),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ref.read(uploadProvider.notifier).setCategory(newValue);
                      }
                    },
                    items: <String>['Opinion', 'Experience', 'Adventure']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Caption with profile pic like Instagram  
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    
                    // Caption text field
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        focusNode: _captionFocus,
                        decoration: const InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 15),
                        maxLines: 3,
                        minLines: 1,
                        onChanged: (value) => ref.read(uploadProvider.notifier).setCaption(value),
                      ),
                    ),
                  ],
                ),
                
                // Audio recording section (if user wants to add audio)
                if (uploadState.wantsToAddAudio)
                  _buildAudioRecordingSection(uploadState),
                
                // Instagram-like additional options
                const SizedBox(height: 16),
                const Divider(height: 1),
                _buildOptionRow(Icons.tag_faces, 'Tag People', _showTagPeopleDialog),
                // Show selected tags
                if (uploadState.taggedUsers != null && uploadState.taggedUsers!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      children: uploadState.taggedUsers!.map<Widget>((user) => Chip(label: Text(user['name']))).toList(),
                    ),
                  ),
                
                // Success message
                if (uploadState.uploadSuccess)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Post shared successfully!',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Instagram-style option row
  Widget _buildOptionRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
  // Audio prompt dialog after image upload
  void _showAudioPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.audiotrack, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text('Add Audio?'),
          ],
        ),
        content: const Text(
          'Would you like to add an audio recording or upload an audio file to enhance your post?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              ref.read(uploadProvider.notifier).declineAudioPrompt();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              ref.read(uploadProvider.notifier).acceptAudioPrompt();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Audio'),
          ),
        ],
      ),
    );
  }

  // Instagram-style discard confirmation dialog
  void _showDiscardConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard post?'),
        content: const Text('If you go back now, your post will be discarded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.go('/home'); // Navigate to home instead of popping twice
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Audio recording section for adding audio to posts
  Widget _buildAudioRecordingSection(UploadState uploadState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        
        // Audio section header
        Row(
          children: [
            const Icon(Icons.audiotrack, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              'Add Audio',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Audio recording controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Record button
            _buildAudioActionButton(
              icon: uploadState.isRecording ? Icons.stop : Icons.mic,
              label: uploadState.isRecording ? 'Stop' : 'Record',
              color: uploadState.isRecording ? Colors.red : Colors.deepPurple,
              onPressed: uploadState.isRecording
                  ? () => ref.read(uploadProvider.notifier).stopAudioRecording()
                  : () async {
                      final hasPermission = await PermissionService.requestMicrophonePermission(context);
                      if (hasPermission && context.mounted) {
                        ref.read(uploadProvider.notifier).startAudioRecording();
                      }
                    },
            ),
            
            // Pick audio file button
            _buildAudioActionButton(
              icon: Icons.audio_file,
              label: 'Pick File',
              color: Colors.blue,
              onPressed: uploadState.isRecording
                  ? null
                  : () async {
                      final hasPermission = await PermissionService.requestAudioPermission(context);
                      if (hasPermission && context.mounted) {
                        ref.read(uploadProvider.notifier).pickAudio();
                      }
                    },
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Show selected audio info
        if (uploadState.audioMedia != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uploadState.audioMedia?.path?.split('/').last ?? 'Audio Recording',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (uploadState.audioMedia?.durationMs != null)
                        Text(
                          'Duration: ${_formatDuration(uploadState.audioMedia!.durationMs!)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(uploadProvider.notifier).clearAudioMedia(),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
          ),
        
        // Recording indicator
        if (uploadState.isRecording)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                const SizedBox(width: 8),
                const Text(
                  'Recording audio...',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(uploadProvider.notifier).cancelAudioRecording(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Helper method to build audio action buttons
  Widget _buildAudioActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Format duration helper method
  String _formatDuration(int milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds);
    final int minutes = duration.inMinutes;
    final int seconds = (duration.inSeconds) % 60;
    
    final String minutesString = '$minutes';
    final String secondsString = seconds < 10 ? '0$seconds' : '$seconds';
    
    return '$minutesString:$secondsString';
  }

  // Tag People dialog
  void _showTagPeopleDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _TagPeopleSheet(
          onTagSelected: (user) {
            ref.read(uploadProvider.notifier).addTaggedUser(user);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

// Tag People bottom sheet widget
class _TagPeopleSheet extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic> user) onTagSelected;
  const _TagPeopleSheet({required this.onTagSelected});

  @override
  ConsumerState<_TagPeopleSheet> createState() => _TagPeopleSheetState();
}

class _TagPeopleSheetState extends ConsumerState<_TagPeopleSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final res = await http.get(Uri.parse('http://10.0.2.2:8001/api/social-service/features/search/users/?q=$query'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _results = List<Map<String, dynamic>>.from(data['results']);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search users',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchUsers,
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (!_loading)
            ..._results.map((user) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user['name'] ?? ''),
                  subtitle: Text(user['email'] ?? ''),
                  onTap: () => widget.onTagSelected(user),
                )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
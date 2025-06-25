import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_model.dart';
import '../providers/upload_provider.dart';
import '../services/permission_service.dart';
import '../widgets/media_preview_card.dart';
import '../widgets/simple_file_input.dart';

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
    
    // Update controller if state changes externally
    if (_captionController.text != uploadState.caption) {
      _captionController.text = uploadState.caption;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: uploadState.isValid && !uploadState.isUploading
                ? () => _uploadPost()
                : null,
            child: uploadState.isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'POST',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message
                if (uploadState.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      uploadState.error!,
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  ),

                // Upload success message
                if (uploadState.uploadSuccess)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Text(
                      'Post uploaded successfully!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),

                // Caption input
                TextField(
                  controller: _captionController,
                  focusNode: _captionFocus,
                  decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16),
                  maxLines: 5,
                  minLines: 1,
                  onChanged: (value) => ref.read(uploadProvider.notifier).setCaption(value),
                ),

                const SizedBox(height: 16),

                // Media preview
                if (uploadState.hasMedia)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: MediaPreviewCard(
                      media: uploadState.selectedMedia!,
                      onDelete: () => ref.read(uploadProvider.notifier).clearMedia(),
                    ),
                  )
                else
                  const Text(
                    'Add to your post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 16),

                // Media options
                if (!uploadState.hasMedia)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildMediaOptionButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onPressed: () async {
                          final hasPermission = await PermissionService.requestStoragePermission(context);
                          if (hasPermission && context.mounted) {
                            ref.read(uploadProvider.notifier).pickImage(false);
                          }
                        },
                      ),
                      _buildMediaOptionButton(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onPressed: () async {
                          final hasPermission = await PermissionService.requestCameraPermission(context);
                          if (hasPermission && context.mounted) {
                            ref.read(uploadProvider.notifier).pickImage(true);
                          }
                        },
                      ),
                      _buildMediaOptionButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        onPressed: () async {
                          final hasPermission = await PermissionService.requestVideoPermission(context);
                          if (hasPermission && context.mounted) {
                            ref.read(uploadProvider.notifier).pickVideo();
                          }
                        },
                      ),
                      _buildMediaOptionButton(
                        icon: Icons.audiotrack,
                        label: 'Audio',
                        onPressed: () async {
                          final hasPermission = await PermissionService.requestAudioPermission(context);
                          if (hasPermission && context.mounted) {
                            ref.read(uploadProvider.notifier).pickAudio();
                          }
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _uploadPost() {
    FocusScope.of(context).unfocus();
    ref.read(uploadProvider.notifier).uploadPost();
  }
}
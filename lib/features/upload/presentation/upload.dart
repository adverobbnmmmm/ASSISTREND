import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/upload_provider.dart';
import '../services/permission_service.dart';
import '../widgets/media_preview_card.dart';
import '../widgets/recent_media_thumbnail.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}




class _UploadPageState extends ConsumerState<UploadPage> with SingleTickerProviderStateMixin {
  late TextEditingController _captionController;
  final FocusNode _captionFocus = FocusNode();
  late TabController _tabController;
  
  // Instagram-like filter options with names and icons
  int _selectedFilterIndex = 0;
  final List<Map<String, dynamic>> _filterOptions = [
    {'name': 'Normal', 'icon': Icons.auto_fix_off},
    {'name': 'Clarendon', 'icon': Icons.auto_awesome},
    {'name': 'Gingham', 'icon': Icons.grain},
    {'name': 'Moon', 'icon': Icons.nights_stay},
    {'name': 'Lark', 'icon': Icons.flare},
    {'name': 'Reyes', 'icon': Icons.blur_on},
    {'name': 'Juno', 'icon': Icons.tonality},
    {'name': 'Slumber', 'icon': Icons.bedtime},
    {'name': 'Crema', 'icon': Icons.filter_vintage},
    {'name': 'Ludwig', 'icon': Icons.monochrome_photos},
    {'name': 'Aden', 'icon': Icons.wb_sunny},
    {'name': 'Perpetua', 'icon': Icons.filter_drama},
  ];
  
  // Instagram-like editing tabs
  final List<String> _editTabs = ['Filter', 'Edit'];
  
  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    


    // Reset upload state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _captionFocus.dispose();
    _tabController.dispose();
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

          // Use a post-frame callback to show SnackBar only (navigation handled in button)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final uploadState = ref.read(uploadProvider);
            if (uploadState.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload failed: ${uploadState.error}')), 
              );
            }
          });

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
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        if (uploadState.hasMedia)
          IconButton(
            onPressed: () {
              // Go to next step - caption
              setState(() {
                // In a real implementation, this might navigate to another step
              });
            },
            icon: const Icon(Icons.arrow_forward, color: Colors.blue),
          ),
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
  
  // Instagram-style media selection screen with large buttons and grid
  Widget _buildMediaSelectionView(BuildContext context, UploadState uploadState) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create New Post',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Instagram-style media options
            SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMediaSelectionCard(
                title: 'Photo',
                icon: Icons.camera_alt,
                onTap: () async {
                  final hasPermission = await PermissionService.requestCameraPermission(context);
                  if (hasPermission && context.mounted) {
                    ref.read(uploadProvider.notifier).pickImage();
                  }
                },
              ),
              _buildMediaSelectionCard(
                title: 'Video',
                icon: Icons.videocam,
                onTap: () async {
                  final hasPermission = await PermissionService.requestCameraPermission(context); // Assuming camera permission covers video
                  if (hasPermission && context.mounted) {
                    ref.read(uploadProvider.notifier).pickVideo();
                  }
                },
              ),
              _buildMediaSelectionCard(
                title: 'Gallery',
                icon: Icons.photo_library,
                onTap: () async {
                  final hasPermission = await PermissionService.requestStoragePermission(context);
                  if (hasPermission && context.mounted) {
                    ref.read(uploadProvider.notifier).pickImage();
                  }
                },
              ),
              _buildMediaSelectionCard(
                title: 'Video',
                icon: Icons.videocam,
                onTap: () async {
                  final hasPermission = await PermissionService.requestVideoPermission(context);
                  if (hasPermission && context.mounted) {
                    ref.read(uploadProvider.notifier).pickVideo();
                  }
                },
              ),
            ],
          ),
      ),
          const SizedBox(height: 32),
          
          // Recent photos from gallery (now showing actual photos)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Photos',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Refresh button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        ref.read(uploadProvider.notifier).loadRecentMedia();
                      },
                      tooltip: 'Refresh gallery',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Gallery content
                if (uploadState.isLoadingRecentMedia)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                    child: uploadState.recentMedia.isEmpty
                        ? const Center(
                            child: Text(
                              'No recent photos found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemCount: uploadState.recentMedia.length,
                            itemBuilder: (context, index) {
                              final media = uploadState.recentMedia[index];
                              return RecentMediaThumbnail(
                                media: media,
                                onTap: () async {
                                  final hasPermission = await PermissionService.requestStoragePermission(context);
                                  if (hasPermission && context.mounted) {
                                    await ref.read(uploadProvider.notifier).selectRecentMedia(media);
                                  }
                                },
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
          
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
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
  
  // Instagram-style post creation view with media preview, tabs for filters and edit
  Widget _buildPostCreationView(UploadState uploadState, BuildContext context, double screenWidth) {
    return Column(
      children: [
        // Media preview (square like Instagram)
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
        
        // Instagram-style tab bar
        TabBar(
          controller: _tabController,
          tabs: _editTabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: Colors.blue,
          indicatorColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
        
        // Filter or Edit content
        if (!uploadState.isUploading)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilterView(),
                _buildEditView(),
              ],
            ),
          ),
        
        const Divider(height: 1),
        
        // Caption and options section at the bottom
        Container(
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
                  // Profile image
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade700,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
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
              
              // Instagram-like additional options
              const SizedBox(height: 16),
              _buildOptionRow(Icons.location_on_outlined, 'Add Location', () {}),
              const Divider(height: 1),
              _buildOptionRow(Icons.tag_faces, 'Tag People', () {}),
              const Divider(height: 1),
              _buildOptionRow(Icons.visibility_outlined, 'Audience', () {}),
              
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
      ],
    );
  }
  
  // Instagram-style filter view with a horizontal carousel
  Widget _buildFilterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              return _buildFilterOption(index);
            },
          ),
        ),
        
        // Filter intensity slider (for selected filter)
        if (_selectedFilterIndex > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _filterOptions[_selectedFilterIndex]['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('100%'),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.grey.shade700,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: 100,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      // Would apply filter with intensity here
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  // Instagram-style edit view with adjustment options
  Widget _buildEditView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAdjustmentOption('Brightness', Icons.brightness_6, 50),
          _buildAdjustmentOption('Contrast', Icons.contrast, 50),
          _buildAdjustmentOption('Structure', Icons.grain, 50),
          _buildAdjustmentOption('Warmth', Icons.whatshot, 50),
          _buildAdjustmentOption('Saturation', Icons.gradient, 50),
          _buildAdjustmentOption('Color', Icons.colorize, 50),
          _buildAdjustmentOption('Fade', Icons.blur_on, 50),
          _buildAdjustmentOption('Highlights', Icons.highlight, 50),
          _buildAdjustmentOption('Shadows', Icons.opacity, 50),
          _buildAdjustmentOption('Vignette', Icons.vignette, 50),
          _buildAdjustmentOption('Tilt Shift', Icons.blur_circular, 50),
          _buildAdjustmentOption('Sharpen', Icons.details, 50),
        ],
      ),
    );
  }
  
  // Instagram-style adjustment option
  Widget _buildAdjustmentOption(String name, IconData icon, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey.shade700,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: (newValue) {
                  // Would apply adjustment here
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Instagram-style filter option
  Widget _buildFilterOption(int index) {
    final isSelected = _selectedFilterIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
                border: isSelected 
                  ? Border.all(color: Colors.white, width: 2) 
                  : null,
              ),
              child: Icon(
                _filterOptions[index]['icon'],
                color: Colors.white, 
                size: 30,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _filterOptions[index]['name'],
              style: TextStyle(
                fontSize: 12, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : null,
              ),
            ),
          ],
        ),
      ),
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


}
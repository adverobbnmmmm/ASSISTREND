import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

import '../models/upload_model.dart';
import '../../search/models/user_model.dart';
import '../services/platform_media_service.dart';
import '../services/mobile_media_picker.dart';
import '../services/gallery_service.dart';
import '../services/audio_recorder_service.dart';
import '../../../shared/utils/storage.dart';

// Define state for upload feature
class UploadState {
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final UploadMedia? selectedMedia;
  final String caption;
  final bool uploadSuccess;
  final String? selectedFilter;
  final Map<String, double>? adjustments;
  final List<String>? tags;
  final String? location;
  final List<RecentMedia> recentMedia;
  final bool isLoadingRecentMedia;
  final String? category;
  final bool isRecording;
  final int? recordingDurationMs;
  final bool showAudioPrompt; // Show prompt to add audio after image selection
  final bool wantsToAddAudio; // User chose to add audio
  final UploadMedia? audioMedia; // Separate audio file
  final List<UserModel> taggedUsers;

  UploadState({
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.selectedMedia,
    this.caption = '',
    this.uploadSuccess = false,
    this.selectedFilter,
    this.adjustments,
    this.tags,
    this.location,
    this.recentMedia = const [],
    this.isLoadingRecentMedia = false,
    this.category,
    this.isRecording = false,
    this.recordingDurationMs,
    this.showAudioPrompt = false,
    this.wantsToAddAudio = false,
    this.audioMedia,
    this.taggedUsers = const [],
  });

  UploadState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? error,
    UploadMedia? selectedMedia,
    String? caption,
    bool? uploadSuccess,
    String? selectedFilter,
    Map<String, double>? adjustments,
    List<String>? tags,
    String? location,
    List<RecentMedia>? recentMedia,
    bool? isLoadingRecentMedia,
    String? category,
    bool? isRecording,
    int? recordingDurationMs,
    bool? showAudioPrompt,
    bool? wantsToAddAudio,
    UploadMedia? audioMedia,
    List<UserModel>? taggedUsers,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      caption: caption ?? this.caption,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      adjustments: adjustments ?? this.adjustments,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      recentMedia: recentMedia ?? this.recentMedia,
      isLoadingRecentMedia: isLoadingRecentMedia ?? this.isLoadingRecentMedia,
      category: category ?? this.category,
      isRecording: isRecording ?? this.isRecording,
      recordingDurationMs: recordingDurationMs ?? this.recordingDurationMs,
      showAudioPrompt: showAudioPrompt ?? this.showAudioPrompt,
      wantsToAddAudio: wantsToAddAudio ?? this.wantsToAddAudio,
      audioMedia: audioMedia ?? this.audioMedia,
      taggedUsers: taggedUsers ?? this.taggedUsers,
    );
  }

  bool get isValid => caption.isNotEmpty || selectedMedia != null || audioMedia != null;
  bool get hasMedia => selectedMedia != null || audioMedia != null;
  bool get hasRecentMedia => recentMedia.isNotEmpty;
}

// Provider notifier to handle upload state
class UploadNotifier extends StateNotifier<UploadState> {
  final PlatformMediaService _mediaService;

  UploadNotifier(this._mediaService) : super(UploadState());

  // Add a tagged user
  void addTaggedUser(UserModel user) {
    if (!state.taggedUsers.contains(user)) {
      final updated = List<UserModel>.from(state.taggedUsers)..add(user);
      state = state.copyWith(taggedUsers: updated);
    }
  }

  // Remove a tagged user
  void removeTaggedUser(UserModel user) {
    final updated = List<UserModel>.from(state.taggedUsers)..remove(user);
    state = state.copyWith(taggedUsers: updated);
  }
  
  // Load recent media from gallery
  Future<void> loadRecentMedia() async {
    // Skip for non-mobile platforms
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('UploadProvider: Skipping recent media load for non-mobile platform');
      // Add mock recent media
      state = state.copyWith(
        recentMedia: List.generate(
          15,
          (i) => RecentMedia(
            path: 'mock_$i.jpg',
            type: i % 3 == 0 ? MediaType.video : MediaType.image,
            timestamp: DateTime.now().subtract(Duration(hours: i)),
            isMock: true,
          ),
        ),
        isLoadingRecentMedia: false,
      );
      return;
    }
    
    try {
      state = state.copyWith(isLoadingRecentMedia: true);
      debugPrint('UploadProvider: Loading recent media...');
      
      // Using updated GalleryService that doesn't depend on photo_manager
      final recentMedia = await GalleryService.getRecentMedia(limit: 30);
      
      state = state.copyWith(
        recentMedia: recentMedia,
        isLoadingRecentMedia: false,
      );
      
      debugPrint('UploadProvider: Loaded ${recentMedia.length} recent media items');
    } catch (e) {
      debugPrint('UploadProvider: Failed to load recent media: $e');
      state = state.copyWith(
        error: 'Failed to load recent photos: $e',
        isLoadingRecentMedia: false,
      );
    }
  }
  
  // Select media from recent media
  Future<void> selectRecentMedia(RecentMedia media) async {
    debugPrint('UploadProvider: Selected recent media: ${media.path}');
    
    state = state.copyWith(isLoading: true);
    
    // For mock media placeholders, we need to pick the actual media
    if (media.isMock) {
      final UploadMedia? selectedMedia = media.isVideo 
        ? await GalleryService.pickVideoFromGallery()
        : await GalleryService.pickImageFromGallery();
        
      if (selectedMedia != null) {
        state = state.copyWith(
          selectedMedia: selectedMedia,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
        );
      }
    } else {
      // For real media, use the existing flow
      final uploadMedia = media.toUploadMedia();
      state = state.copyWith(selectedMedia: uploadMedia, isLoading: false);
    }
  }
  
  // Update caption text
  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  // Reset the upload state
  void reset() {
    state = UploadState();
  }

  // Clear selected media
  void clearMedia() {
    state = state.copyWith(selectedMedia: null);
  }
  
  // Set location
  void setLocation(String location) {
    state = state.copyWith(location: location);
  }
  
  // Set tags
  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }
  
  // Set filter
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
  
  // Update adjustments
  void updateAdjustment(String adjustment, double value) {
    final currentAdjustments = state.adjustments ?? {};
    final updatedAdjustments = Map<String, double>.from(currentAdjustments);
    updatedAdjustments[adjustment] = value;
    
    state = state.copyWith(adjustments: updatedAdjustments);
  }

  // Set category
  void setCategory(String category) {
    state = state.copyWith(category: category);
  }
  
  // Pick image
  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      debugPrint('UploadProvider: Attempting to pick image');

      // First try platform service
      final media = await _mediaService.pickImage(fromCamera);

      if (media != null) {
        // For desktop/mock platforms, just use the mock media
        debugPrint('UploadProvider: Received media from platform service');
        state = state.copyWith(
          selectedMedia: media,
          isLoading: false,
          showAudioPrompt: media.type == MediaType.image, // Show audio prompt for images
        );
        debugPrint('UploadProvider: showAudioPrompt set to ${state.showAudioPrompt}');
      } else {
        // On mobile platforms, we need to actually use image_picker
        // since platform service returned null
        try {
          // Use our MobileMediaPicker implementation for actual mobile devices
          debugPrint('UploadProvider: Calling MobileMediaPicker.pickImage()');
          final mobileMedia = await MobileMediaPicker.pickImage(fromCamera);

          if (mobileMedia != null) {
            debugPrint('UploadProvider: Received media with path: ${mobileMedia.path}');
            debugPrint('UploadProvider: File exists: ${mobileMedia.file?.existsSync()}');

            state = state.copyWith(
              selectedMedia: mobileMedia,
              isLoading: false,
              showAudioPrompt: mobileMedia.type == MediaType.image, // Show audio prompt for images
            );
            debugPrint('UploadProvider: showAudioPrompt set to ${state.showAudioPrompt}');
          } else {
            // User canceled the picker
            debugPrint('UploadProvider: Image selection canceled by user');
            state = state.copyWith(isLoading: false);
          }
        } catch (pickerError) {
          debugPrint('Error using image picker: $pickerError');
          state = state.copyWith(
            error: 'Failed to pick image: $pickerError',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      debugPrint('UploadProvider: Exception during image picking: $e');
      state = state.copyWith(
        error: 'Failed to pick image: $e',
        isLoading: false,
      );
    }
  }

  // Pick video
  Future<void> pickVideo({bool fromCamera = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      debugPrint('UploadProvider: Attempting to pick video from ${fromCamera ? "camera" : "gallery"}');

      // Use platform-specific implementation
      final media = await _mediaService.pickVideo();

      if (media != null) {
        // For desktop/mock platforms
        debugPrint('UploadProvider: Received video from platform service');
        state = state.copyWith(
          selectedMedia: media,
          isLoading: false,
        );
      } else {
        // On mobile platforms, we need to use the actual video picker
        try {
          // Use our MobileMediaPicker implementation
          debugPrint('UploadProvider: Attempting to pick video with MobileMediaPicker');
          final mobileMedia = await MobileMediaPicker.pickVideo(fromCamera: fromCamera);

          if (mobileMedia != null) {
            debugPrint('UploadProvider: Video successfully picked:');
            debugPrint('  - Path: ${mobileMedia.path}');
            debugPrint('  - File exists: ${mobileMedia.file?.existsSync() ?? false}');
            debugPrint('  - Has thumbnail: ${mobileMedia.thumbnail != null}');
            debugPrint('  - Duration: ${mobileMedia.durationMs != null ? "${mobileMedia.durationMs}ms" : "unknown"}');

            state = state.copyWith(
              selectedMedia: mobileMedia,
              isLoading: false,
            );
          } else {
            // User canceled the picker
            debugPrint('UploadProvider: Video selection canceled by user');
            state = state.copyWith(isLoading: false);
          }
        } catch (pickerError) {
          debugPrint('Error using video picker: $pickerError');
          state = state.copyWith(
            error: 'Failed to pick video: $pickerError',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      debugPrint('UploadProvider: Exception during video picking: $e');
      state = state.copyWith(
        error: 'Failed to pick video: $e',
        isLoading: false,
      );
    }
  }

  // Upload to Cloudinary
  Future<String?> uploadToCloudinary(String filePath, MediaType mediaType) async {
    final cloudinary = CloudinaryPublic('dwnhpd6oe', 'unsigned_preset', cache: false);
    try {
      CloudinaryResourceType resourceType;
      switch (mediaType) {
        case MediaType.video:
          resourceType = CloudinaryResourceType.Video;
          break;
        case MediaType.audio:
          resourceType = CloudinaryResourceType.Video; // Cloudinary treats audio as video resource
          break;
        case MediaType.image:
          resourceType = CloudinaryResourceType.Image;
          break;
      }

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath, resourceType: resourceType),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint('Cloudinary Error: ${e.message}');
      return null;
    }
  }

  // Handle upload process
  Future<void> handleUpload() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please select media or enter a caption.');
      return;
    }

    state = state.copyWith(isUploading: true, error: null);

    try {
      String? mediaUrl;
      String? audioUrl;
      
      // Upload main media (image/video)
      if (state.selectedMedia != null) {
        if (state.selectedMedia?.path != null) {
          final String mediaPath = state.selectedMedia?.path ?? '';
          mediaUrl = await uploadToCloudinary(mediaPath, state.selectedMedia!.type);
        }
        
        if (mediaUrl == null) {
          throw Exception('Failed to upload media to Cloudinary.');
        }
      }
      
      // Upload audio media separately if present
      if (state.audioMedia != null) {
        if (state.audioMedia?.path != null) {
          final String audioPath = state.audioMedia?.path ?? '';
          audioUrl = await uploadToCloudinary(audioPath, state.audioMedia!.type);
        }
        
        if (audioUrl == null) {
          throw Exception('Failed to upload audio to Cloudinary.');
        }
      }
      
      final url = 'http://10.0.2.2:8001';
      
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'userId': await Storage.getUserId(),
        'caption': state.caption,
        'category': state.category,
      };
      
      // Add URLs based on what was uploaded
      if (mediaUrl != null) {
        requestBody['imageUrl'] = mediaUrl;
      }
      if (audioUrl != null) {
        requestBody['audioUrl'] = audioUrl;
      }
      
      await http.post(
        Uri.parse('${url}/api/social-service/features/uploadPost/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      // Log upload details
      debugPrint('Uploading: Caption: ${state.caption}, Media URL: $mediaUrl, Audio URL: $audioUrl, Filter: ${state.selectedFilter}, Adjustments: ${state.adjustments}, Tags: ${state.tags}, Location: ${state.location}');

      state = state.copyWith(isUploading: false, uploadSuccess: true);
      debugPrint('Upload successful!');
    } catch (e) {
      debugPrint('Upload failed: $e');
      state = state.copyWith(isUploading: false, error: 'Upload failed: $e');
    }
  }

  // Pick audio
  Future<void> pickAudio() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Use platform-specific implementation
      final media = await _mediaService.pickAudio();
      
      if (media != null) {
        // For desktop/mock platforms
        state = state.copyWith(
          audioMedia: media, // Set as audio media
          isLoading: false,
        );
      } else {
        // On mobile platforms, we need to use the actual file picker
        try {
          // Use our MobileMediaPicker implementation
          final mobileMedia = await MobileMediaPicker.pickAudio();
          
          if (mobileMedia != null) {
            state = state.copyWith(
              audioMedia: mobileMedia, // Set as audio media
              isLoading: false,
            );
          } else {
            // User canceled the picker
            state = state.copyWith(isLoading: false);
          }
        } catch (pickerError) {
          debugPrint('Error using audio picker: $pickerError');
          state = state.copyWith(
            error: 'Failed to pick audio: $pickerError',
            isLoading: false,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to pick audio: $e',
        isLoading: false,
      );
    }
  }

  // Clear selected media
  void clearSelectedMedia() {
    state = state.copyWith(selectedMedia: null);
  }

  // Start audio recording
  Future<void> startAudioRecording() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await AudioRecorderService.startRecording();
      if (success) {
        state = state.copyWith(
          isRecording: true,
          isLoading: false,
        );
        debugPrint('UploadProvider: Audio recording started');
      } else {
        state = state.copyWith(
          error: 'Failed to start recording. Please check microphone permissions.',
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('UploadProvider: Error starting audio recording: $e');
      state = state.copyWith(
        error: 'Failed to start recording: $e',
        isLoading: false,
      );
    }
  }

  // Stop audio recording
  Future<void> stopAudioRecording() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final media = await AudioRecorderService.stopRecording();
      if (media != null) {
        state = state.copyWith(
          audioMedia: media, // Set as audio media, not selectedMedia
          isRecording: false,
          isLoading: false,
        );
        debugPrint('UploadProvider: Audio recording stopped and saved');
      } else {
        state = state.copyWith(
          error: 'Failed to save recording',
          isRecording: false,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('UploadProvider: Error stopping audio recording: $e');
      state = state.copyWith(
        error: 'Failed to stop recording: $e',
        isRecording: false,
        isLoading: false,
      );
    }
  }

  // Cancel audio recording
  Future<void> cancelAudioRecording() async {
    try {
      await AudioRecorderService.cancelRecording();
      state = state.copyWith(
        isRecording: false,
        recordingDurationMs: null,
      );
      debugPrint('UploadProvider: Audio recording canceled');
    } catch (e) {
      debugPrint('UploadProvider: Error canceling audio recording: $e');
      state = state.copyWith(
        error: 'Failed to cancel recording: $e',
        isRecording: false,
      );
    }
  }

  // Accept audio prompt and start audio recording/selection
  void acceptAudioPrompt() {
    state = state.copyWith(
      showAudioPrompt: false,
      wantsToAddAudio: true,
    );
  }

  // Decline audio prompt and proceed without audio
  void declineAudioPrompt() {
    state = state.copyWith(
      showAudioPrompt: false,
      wantsToAddAudio: false,
    );
  }

  // Set audio media separately from main media
  void setAudioMedia(UploadMedia audioMedia) {
    state = state.copyWith(audioMedia: audioMedia);
  }

  // Clear audio media
  void clearAudioMedia() {
    state = state.copyWith(audioMedia: null);
  }
  




  // Upload post - Instagram-like flow
  Future<void> uploadPost() async {
    if (!state.isValid) {
      state = state.copyWith(
        error: 'Please add a caption or select media to upload',
      );
      return;
    }

    try {
      state = state.copyWith(isUploading: true, error: null);
      
      // Create post object with all Instagram-like metadata
      final post = UploadPost(
        media: state.selectedMedia,
        caption: state.caption,
        createdAt: DateTime.now(),
      );
      
      // Log the upload attempt
      debugPrint('UploadProvider: Uploading post with:');
      debugPrint(' - Caption: ${post.caption}');
      debugPrint(' - Media type: ${post.hasMedia ? post.media!.type.toString() : "none"}');
      if (state.selectedFilter != null) {
        debugPrint(' - Filter: ${state.selectedFilter}');
      }
      if (state.location != null) {
        debugPrint(' - Location: ${state.location}');
      }
      
      // Simulate network request with steps like Instagram
      debugPrint('UploadProvider: Preparing media for upload...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('UploadProvider: Applying filters and adjustments...');
      await Future.delayed(const Duration(milliseconds: 700));
      
      debugPrint('UploadProvider: Uploading to server...');
      await Future.delayed(const Duration(seconds: 1));
      
      debugPrint('UploadProvider: Processing...');
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mark as success
      state = state.copyWith(
        isUploading: false,
        uploadSuccess: true,
      );
      
      // Reset the form after successful upload
      debugPrint('UploadProvider: Upload completed successfully!');
      Future.delayed(const Duration(seconds: 2), () {
        reset();
      });
    } catch (e) {
      debugPrint('UploadProvider: Error during upload: $e');
      state = state.copyWith(
        error: 'Upload failed: $e',
        isUploading: false,
      );
    }
  }

  // Dispose resources
  @override
  void dispose() {
    // Cancel any ongoing recording
    if (state.isRecording) {
      AudioRecorderService.cancelRecording();
    }
    super.dispose();
  }
}

// Create the provider for platform-specific media service
final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final mediaService = ref.watch(platformMediaServiceProvider);
  return UploadNotifier(mediaService);
});

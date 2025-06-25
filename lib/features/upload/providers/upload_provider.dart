import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/upload_model.dart';
import '../services/platform_media_service.dart';
import '../services/mobile_media_picker.dart';

// Define state for upload feature
class UploadState {
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final UploadMedia? selectedMedia;
  final String caption;
  final bool uploadSuccess;

  UploadState({
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.selectedMedia,
    this.caption = '',
    this.uploadSuccess = false,
  });

  UploadState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? error,
    UploadMedia? selectedMedia,
    String? caption,
    bool? uploadSuccess,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      caption: caption ?? this.caption,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
    );
  }

  bool get isValid => caption.isNotEmpty || selectedMedia != null;
  bool get hasMedia => selectedMedia != null;
}

// Provider notifier to handle upload state
class UploadNotifier extends StateNotifier<UploadState> {
  final PlatformMediaService _mediaService;

  UploadNotifier(this._mediaService) : super(UploadState());
  
  // Update caption text
  void setCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  // Reset state
  void reset() {
    state = UploadState();
  }
  // Pick image from camera or gallery
  Future<void> pickImage(bool fromCamera) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Use our platform-specific service 
      final media = await _mediaService.pickImage(fromCamera);
      
      if (media != null) {
        // For desktop/mock platforms, just use the mock media
        state = state.copyWith(
          selectedMedia: media,
          isLoading: false,
        );
      } else {
        // On mobile platforms, we need to actually use image_picker
        // since platform service returned null
        try {
          // Use our MobileMediaPicker implementation for actual mobile devices
          debugPrint('UploadProvider: Calling MobileMediaPicker.pickImage(${fromCamera})');
          final mobileMedia = await MobileMediaPicker.pickImage(fromCamera);
          
          if (mobileMedia != null) {
            debugPrint('UploadProvider: Received media with path: ${mobileMedia.path}');
            debugPrint('UploadProvider: File exists: ${mobileMedia.file?.existsSync()}');
            
            state = state.copyWith(
              selectedMedia: mobileMedia,
              isLoading: false,
            );
          } else {
            // User canceled the picker
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
      state = state.copyWith(
        error: 'Failed to pick image: $e',
        isLoading: false,
      );
    }
  }
  // Pick video
  Future<void> pickVideo() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Use platform-specific implementation
      final media = await _mediaService.pickVideo();
      
      if (media != null) {
        // For desktop/mock platforms
        state = state.copyWith(
          selectedMedia: media,
          isLoading: false,
        );
      } else {
        // On mobile platforms, we need to use the actual video picker
        try {
          // Use our MobileMediaPicker implementation
          debugPrint('UploadProvider: Attempting to pick video with MobileMediaPicker');
          final mobileMedia = await MobileMediaPicker.pickVideo();
          
          if (mobileMedia != null) {
            debugPrint('UploadProvider: Video successfully picked:');
            debugPrint('  - Path: ${mobileMedia.path}');
            debugPrint('  - File exists: ${mobileMedia.file?.existsSync() ?? false}');
            debugPrint('  - Has thumbnail: ${mobileMedia.thumbnail != null}');
            
            state = state.copyWith(
              selectedMedia: mobileMedia,
              isLoading: false,
            );
          } else {
            // User canceled the picker
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
      state = state.copyWith(
        error: 'Failed to pick video: $e',
        isLoading: false,
      );
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
          selectedMedia: media,
          isLoading: false,
        );
      } else {
        // On mobile platforms, we need to use the actual file picker
        try {
          // Use our MobileMediaPicker implementation
          final mobileMedia = await MobileMediaPicker.pickAudio();
          
          if (mobileMedia != null) {
            state = state.copyWith(
              selectedMedia: mobileMedia,
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
  void clearMedia() {
    state = state.copyWith(selectedMedia: null);
  }

  // Upload post
  Future<void> uploadPost() async {
    if (!state.isValid) {
      state = state.copyWith(
        error: 'Please add a caption or select media to upload',
      );
      return;
    }

    try {
      state = state.copyWith(isUploading: true, error: null);
      
      // Create post object (using but not storing yet)
      final post = UploadPost(
        media: state.selectedMedia,
        caption: state.caption,
        createdAt: DateTime.now(),
      );
      
      // Mock the upload process
      debugPrint('Would upload post: ${post.caption}');
      
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        isUploading: false,
        uploadSuccess: true,
      );
      
      // Reset the form after successful upload
      Future.delayed(const Duration(seconds: 1), () {
        reset();
      });
    } catch (e) {
      state = state.copyWith(
        error: 'Upload failed: $e',
        isUploading: false,
      );
    }
  }
}

// Create the provider for platform-specific media service
final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final mediaService = ref.watch(platformMediaServiceProvider);
  return UploadNotifier(mediaService);
});

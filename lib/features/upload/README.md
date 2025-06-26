# Instagram-Style Upload Feature

This module implements an Instagram-like upload experience for photos, videos, and audio content in the Assistrend app. The implementation closely follows Instagram's UI/UX patterns for media uploading and sharing.

## Features

### Media Selection
- Select photos from gallery
- Take photos with camera
- Record or select videos
- Upload audio files with preview
- Permission handling for camera, gallery, and storage
- Recent media grid (similar to Instagram)

### Instagram-Style Preview and Editing
- Square preview (1:1 aspect ratio) for media
- Filter carousel with named visual effects (Clarendon, Gingham, Moon, etc.)
- Adjustment tools (brightness, contrast, structure, warmth, etc.)
- Caption input with user profile image
- Location tagging, people tagging, and audience selection

### Video Features
- Auto-playing videos in preview
- Instagram-like video controls with fade-out UI
- Progress indicator and duration display
- Thumbnail generation for videos
- Video playback controls

### Cross-Platform Support
- Mobile implementation using native pickers
- Desktop fallback with mock media
- Platform-specific permission handling

## Implementation

### Models

- `UploadMedia`: Represents media (image, video, audio) with Instagram-style properties
- `UploadPost`: Represents a complete post with media, caption, location, tags, and filters

### Services

- `PermissionService`: Handles Android runtime permissions for media access
- `PlatformMediaService`: Platform abstraction for media picking
- `MobileMediaPicker`: Mobile-specific implementation for media selection

### Providers

- `UploadNotifier`: Riverpod state management for Instagram-like upload operations
- `uploadProvider`: Provider to access the upload state and operations

### UI Components

- `MediaPreviewCard`: Instagram-style media preview display
- `VideoPreviewPlayer`: Custom video player with Instagram-like controls
- `SimpleFileInput`: Basic UI for selecting files

## Dependencies

- `image_picker`: For selecting images/videos from gallery or camera
- `file_picker`: For selecting audio files
- `video_thumbnail`: For generating video thumbnails
- `video_player`: For video playback with controls
- `permission_handler`: For handling runtime permissions
- `flutter_riverpod`: For state management
- `path_provider`: For file path handling

## Instagram-Style Flow

1. User taps the "+" icon in the bottom navigation bar
2. User selects media type (photo, gallery, video)
3. User adds filters and edits the media with Instagram-like tools
4. User adds a caption, location, tags and selects audience
5. User shares the post with the "Share" button
6. Success animation shown after posting

## Permissions

The following permissions are required:
- Camera: For taking photos and videos
- Storage: For accessing gallery images/videos
- Audio: For accessing audio files

## Platform Compatibility

- Android: Full support with all features
- iOS: Full support with all features (implementation needed)
- Windows/Desktop: Mock implementations with visual consistency

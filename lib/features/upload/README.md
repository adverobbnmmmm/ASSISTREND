# Upload Feature

This module handles media uploads (images, videos, audio) with captions for the Assistrend app.

## Features

- Upload images from gallery or camera
- Upload video with thumbnail generation
- Upload audio files
- Add captions to media posts
- Preview media before posting
- Permission handling for media access
- Error handling and user feedback

## Implementation

### Models

- `UploadMedia`: Represents a media file (image, video, audio) to be uploaded
- `UploadPost`: Represents a complete post with media and caption

### Services

- `PermissionService`: Handles Android runtime permissions for media access

### Providers

- `UploadNotifier`: State management for upload operations
- `uploadProvider`: Riverpod provider to access the upload state

### UI Components

- `MediaPreviewCard`: Displays a preview of the selected media
- `SimpleFileInput`: Basic UI for selecting files

## Dependencies

- `image_picker`: For selecting images/videos from gallery or camera
- `file_picker`: For selecting audio files
- `video_thumbnail`: For generating video thumbnails
- `permission_handler`: For handling runtime permissions
- `flutter_riverpod`: For state management

## Flow

1. User navigates to the Upload page
2. User can select media (image/video/audio) 
3. User adds a caption
4. User previews the post and taps "Post" to upload
5. Success/failure feedback is shown to the user

## Permissions

The following permissions are required:
- Camera: For taking photos
- Storage: For accessing gallery images/videos
- Audio: For accessing audio files

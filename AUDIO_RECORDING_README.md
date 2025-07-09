# Audio Recording Feature

This feature enables users to record audio or upload audio files from their device and include them in posts. The audio is uploaded to Cloudinary and the URL is sent to the backend.

## Features

- **Record Audio**: Record audio directly from the device microphone
- **Upload Audio Files**: Select MP3 or other audio files from device storage
- **Cloudinary Integration**: Audio files are uploaded to Cloudinary for reliable hosting
- **Backend Integration**: Audio URLs are sent to the backend along with post data

## Dependencies Added

```yaml
dependencies:
  record: ^5.1.2        # For audio recording
  audioplayers: ^5.2.1  # For audio playback (optional)
```

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to record audio.</string>
```

## File Structure

```
lib/features/upload/
├── services/
│   └── audio_recorder_service.dart     # Audio recording service
├── providers/
│   └── upload_provider.dart            # Updated with audio support
├── widgets/
│   └── audio_recording_widget.dart     # Audio recording UI
└── models/
    └── upload_model.dart               # Updated with audio support
```

## Usage

### 1. Basic Integration

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/upload/widgets/audio_recording_widget.dart';

class MyAudioPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Recording')),
      body: AudioRecordingWidget(),
    );
  }
}
```

### 2. Using Upload Provider Directly

```dart
// Get the upload provider
final uploadNotifier = ref.read(uploadProvider.notifier);
final uploadState = ref.watch(uploadProvider);

// Start recording
await uploadNotifier.startAudioRecording();

// Stop recording
await uploadNotifier.stopAudioRecording();

// Cancel recording
await uploadNotifier.cancelAudioRecording();

// Pick audio file
await uploadNotifier.pickAudio();

// Upload with audio
await uploadNotifier.handleUpload();
```

## API Integration

The audio URL is sent to the backend in the following format:

```json
{
  "userId": "user_id",
  "caption": "Post caption",
  "category": "post_category",
  "audioUrl": "https://res.cloudinary.com/your-cloud/video/upload/v1234567890/audio_file.m4a"
}
```

## Cloudinary Configuration

Audio files are uploaded to Cloudinary as Video resources (this is normal for audio):

```dart
// In upload_provider.dart
case MediaType.audio:
  resourceType = CloudinaryResourceType.Video; // Cloudinary treats audio as video
  break;
```

## Error Handling

The provider handles various error scenarios:

- **Permission Denied**: When microphone access is denied
- **Recording Failures**: When audio recording fails
- **Upload Failures**: When Cloudinary upload fails
- **Network Errors**: When backend communication fails

## State Management

The `UploadState` includes audio-specific properties:

```dart
class UploadState {
  final bool isRecording;           // Whether currently recording
  final int? recordingDurationMs;   // Recording duration (optional)
  // ... other properties
}
```

## Audio File Support

Supported audio formats:
- MP3
- M4A
- WAV
- AAC
- OGG

## Testing

To test the audio recording feature:

1. Run the app on a physical device (recording doesn't work on emulator)
2. Navigate to the audio recording page
3. Grant microphone permissions when prompted
4. Test recording, stopping, and uploading audio
5. Test picking audio files from device storage

## Troubleshooting

### Common Issues:

1. **"Failed to start recording"**
   - Check microphone permissions
   - Ensure running on physical device
   - Verify `record` package is properly installed

2. **"Failed to upload media to Cloudinary"**
   - Check internet connection
   - Verify Cloudinary credentials
   - Ensure audio file is not corrupted

3. **"Upload failed"**
   - Check backend API endpoint
   - Verify userId exists in storage
   - Check backend logs for detailed error

### Debug Tips:

- Enable debug prints in `audio_recorder_service.dart`
- Check device logs for permission errors
- Test with different audio file formats
- Verify Cloudinary dashboard for uploaded files

## Future Enhancements

Potential improvements:
- Real-time recording duration display
- Audio playback preview before upload
- Audio editing capabilities (trim, effects)
- Multiple audio file support
- Voice-to-text transcription
- Audio quality settings

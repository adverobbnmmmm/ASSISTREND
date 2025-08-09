import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_audio_service.dart';
import '../../upload/services/permission_service.dart';
import '../../home/services/audio_player_service.dart';

/// Widget for managing profile audio - recording, uploading, and playback
class ProfileAudioWidget extends ConsumerStatefulWidget {
  final String? currentAudioUrl;
  final Function(String?) onAudioUpdated;

  const ProfileAudioWidget({
    super.key,
    this.currentAudioUrl,
    required this.onAudioUpdated,
  });

  @override
  ConsumerState<ProfileAudioWidget> createState() => _ProfileAudioWidgetState();
}

class _ProfileAudioWidgetState extends ConsumerState<ProfileAudioWidget> {
  bool _isRecording = false;
  bool _isUploading = false;
  String? _recordedFilePath;
  String? _selectedFilePath;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 8),
              Text(
                'Profile Audio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current audio status
          if (widget.currentAudioUrl != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Profile audio is set',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  // Play button
                  ValueListenableBuilder<bool>(
                    valueListenable: AudioPlayerService.isPlayingNotifier,
                    builder: (context, isPlaying, child) {
                      final isCurrentlyPlaying = AudioPlayerService.isUrlPlaying(widget.currentAudioUrl!);
                      
                      return IconButton(
                        onPressed: () async {
                          if (isCurrentlyPlaying) {
                            await AudioPlayerService.pause();
                          } else {
                            await AudioPlayerService.playFromUrl(widget.currentAudioUrl!);
                          }
                        },
                        icon: Icon(
                          isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No profile audio set',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recording status
          if (_isRecording) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recording...',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // File selected status
          if (_recordedFilePath != null || _selectedFilePath != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.audiotrack, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recordedFilePath != null ? 'Audio recorded' : 'Audio file selected',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _recordedFilePath = null;
                        _selectedFilePath = null;
                      });
                    },
                    child: Text('Clear', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              // Record button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : (_isRecording ? _stopRecording : _startRecording),
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop' : 'Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Pick file button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading || _isRecording ? null : _pickAudioFile,
                  icon: Icon(Icons.audio_file),
                  label: Text('Pick File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          // Cancel recording button (only show when recording)
          if (_isRecording) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cancelRecording,
                child: Text('Cancel Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],

          // Upload button (show when file is ready)
          if ((_recordedFilePath != null || _selectedFilePath != null) && !_isRecording) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadAudio,
                child: _isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Uploading...'),
                        ],
                      )
                    : Text('Upload Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],

          // Remove audio button (show when audio exists)
          if (widget.currentAudioUrl != null && !_isRecording && !_isUploading) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _removeAudio,
                child: Text('Remove Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await PermissionService.requestMicrophonePermission(context);
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Microphone permission is required to record audio';
        });
        return;
      }

      setState(() {
        _isRecording = true;
        _errorMessage = null;
        _recordedFilePath = null;
        _selectedFilePath = null;
      });

      final success = await ProfileAudioService.startRecording();
      if (!success) {
        setState(() {
          _isRecording = false;
          _errorMessage = 'Failed to start recording';
        });
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _errorMessage = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final filePath = await ProfileAudioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedFilePath = filePath;
        if (filePath == null) {
          _errorMessage = 'Failed to save recording';
        }
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
        _errorMessage = 'Error stopping recording: $e';
      });
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await ProfileAudioService.cancelRecording();
      setState(() {
        _isRecording = false;
        _recordedFilePath = null;
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
        _errorMessage = 'Error canceling recording: $e';
      });
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final hasPermission = await PermissionService.requestAudioPermission(context);
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Storage permission is required to access audio files';
        });
        return;
      }

      final filePath = await ProfileAudioService.pickAudioFile();
      setState(() {
        _selectedFilePath = filePath;
        _recordedFilePath = null; // Clear recorded file if any
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking audio file: $e';
      });
    }
  }

  Future<void> _uploadAudio() async {
    final filePath = _recordedFilePath ?? _selectedFilePath;
    if (filePath == null) return;

    try {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
      });

      final audioUrl = await ProfileAudioService.uploadToCloudinary(filePath);
      if (audioUrl != null) {
        widget.onAudioUpdated(audioUrl);
        setState(() {
          _recordedFilePath = null;
          _selectedFilePath = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to upload audio to cloud storage';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading audio: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _removeAudio() async {
    try {
      widget.onAudioUpdated(null);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error removing audio: $e';
      });
    }
  }
}

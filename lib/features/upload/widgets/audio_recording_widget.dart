import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upload_provider.dart';

/// Widget for recording audio and uploading posts with audio
class AudioRecordingWidget extends ConsumerStatefulWidget {
  const AudioRecordingWidget({super.key});

  @override
  ConsumerState<AudioRecordingWidget> createState() => _AudioRecordingWidgetState();
}

class _AudioRecordingWidgetState extends ConsumerState<AudioRecordingWidget> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final uploadNotifier = ref.read(uploadProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recording'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Caption input
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Add a caption...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                uploadNotifier.setCaption(value);
              },
            ),
            const SizedBox(height: 20),

            // Audio controls section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Audio Recording',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recording controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Record button
                      ElevatedButton.icon(
                        onPressed: uploadState.isRecording
                            ? null
                            : () => uploadNotifier.startAudioRecording(),
                        icon: Icon(
                          uploadState.isRecording ? Icons.mic : Icons.mic_none,
                          color: uploadState.isRecording ? Colors.red : null,
                        ),
                        label: Text(
                          uploadState.isRecording ? 'Recording...' : 'Record',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: uploadState.isRecording
                              ? Colors.red.shade100
                              : Colors.deepPurple,
                          foregroundColor: uploadState.isRecording
                              ? Colors.red
                              : Colors.white,
                        ),
                      ),

                      // Stop button
                      ElevatedButton.icon(
                        onPressed: uploadState.isRecording
                            ? () => uploadNotifier.stopAudioRecording()
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      // Cancel button
                      ElevatedButton.icon(
                        onPressed: uploadState.isRecording
                            ? () => uploadNotifier.cancelAudioRecording()
                            : null,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // OR divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pick audio from files
                  ElevatedButton.icon(
                    onPressed: uploadState.isRecording
                        ? null
                        : () => uploadNotifier.pickAudio(),
                    icon: const Icon(Icons.audio_file),
                    label: const Text('Pick Audio File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Selected media display
            if (uploadState.selectedMedia != null || uploadState.audioMedia != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Audio:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.audiotrack, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (uploadState.selectedMedia?.path ?? uploadState.audioMedia?.path)?.split('/').last ?? 'Audio file',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (uploadState.selectedMedia != null) {
                              uploadNotifier.clearSelectedMedia();
                            } else {
                              uploadNotifier.clearAudioMedia();
                            }
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                    if ((uploadState.selectedMedia?.durationMs ?? uploadState.audioMedia?.durationMs) != null)
                      Text(
                        'Duration: ${((uploadState.selectedMedia?.durationMs ?? uploadState.audioMedia?.durationMs)! / 1000).toStringAsFixed(1)}s',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Error display
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

            const Spacer(),

            // Upload button
            ElevatedButton(
              onPressed: uploadState.isUploading ||
                      uploadState.isRecording ||
                      (!uploadState.isValid)
                  ? null
                  : () => uploadNotifier.handleUpload(),
              child: uploadState.isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Uploading...'),
                      ],
                    )
                  : const Text('Upload Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // Success message
            if (uploadState.uploadSuccess)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Post uploaded successfully!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

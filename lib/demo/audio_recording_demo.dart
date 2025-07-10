import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/upload/widgets/audio_recording_widget.dart';

/// Demo page showing how to integrate audio recording functionality
class AudioRecordingDemoPage extends ConsumerWidget {
  const AudioRecordingDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recording Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const AudioRecordingWidget(),
    );
  }
}

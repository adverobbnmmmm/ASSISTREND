import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/upload/presentation/upload.dart';

/// Example of how to use the audio recording feature
class AudioRecordingExample extends ConsumerWidget {
  const AudioRecordingExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Audio Recording Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const UploadPage(),
    );
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: AudioRecordingExample(),
    ),
  );
}

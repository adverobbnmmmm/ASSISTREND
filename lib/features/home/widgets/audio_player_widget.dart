import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  @override
  void initState() {
    super.initState();
    AudioPlayerService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ValueListenableBuilder<bool>(
          valueListenable: AudioPlayerService.isPlayingNotifier,
          builder: (context, isPlaying, child) {
            final isCurrentlyPlaying = AudioPlayerService.isUrlPlaying(widget.audioUrl);
            
            return GestureDetector(
              onTap: () async {
                if (isCurrentlyPlaying) {
                  await AudioPlayerService.pause();
                } else {
                  await AudioPlayerService.playFromUrl(widget.audioUrl);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCurrentlyPlaying ? "Pause" : "Play",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

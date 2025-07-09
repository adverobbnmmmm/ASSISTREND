import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class Playbutton extends StatefulWidget {
  const Playbutton({
    super.key,
    this.audioUrl,
  });

  final String? audioUrl;

  @override
  State<Playbutton> createState() => _PlaybuttonState();
}

class _PlaybuttonState extends State<Playbutton> {
  @override
  void initState() {
    super.initState();
    // Initialize audio player service
    AudioPlayerService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // If no audio URL, don't show the button
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 3,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: AudioPlayerService.isPlayingNotifier,
              builder: (context, isPlaying, child) {
                final isCurrentlyPlaying = AudioPlayerService.isUrlPlaying(widget.audioUrl!);
                
                return TextButton(
                  onPressed: () async {
                    if (isCurrentlyPlaying) {
                      await AudioPlayerService.pause();
                    } else {
                      await AudioPlayerService.playFromUrl(widget.audioUrl!);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCurrentlyPlaying ? "Pause" : "Play",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          // Play/Pause button and title
          Row(
            children: [
              ValueListenableBuilder<bool>(
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Icon(
                        isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Recording',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: AudioPlayerService.currentUrlNotifier,
                      builder: (context, currentUrl, child) {
                        final isCurrentlyPlaying = currentUrl == widget.audioUrl;
                        return Text(
                          isCurrentlyPlaying ? 'Now Playing' : 'Tap to play',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ValueListenableBuilder<Duration>(
            valueListenable: AudioPlayerService.positionNotifier,
            builder: (context, position, child) {
              return ValueListenableBuilder<Duration>(
                valueListenable: AudioPlayerService.durationNotifier,
                builder: (context, duration, child) {
                  final isCurrentAudio = AudioPlayerService.currentUrl == widget.audioUrl;
                  final currentPosition = isCurrentAudio ? position : Duration.zero;
                  final totalDuration = isCurrentAudio ? duration : Duration.zero;
                  
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: Colors.grey[600],
                          thumbColor: Colors.blue,
                          overlayColor: Colors.blue.withAlpha(32),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: totalDuration.inMilliseconds > 0
                              ? (currentPosition.inMilliseconds / totalDuration.inMilliseconds)
                                  .clamp(0.0, 1.0)
                              : 0.0,
                          onChanged: (value) async {
                            if (totalDuration.inMilliseconds > 0) {
                              final newPosition = Duration(
                                milliseconds: (value * totalDuration.inMilliseconds).round(),
                              );
                              await AudioPlayerService.seek(newPosition);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(currentPosition),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(totalDuration),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

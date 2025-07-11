import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class InstagramAudioPlayer extends StatefulWidget {
  const InstagramAudioPlayer({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<InstagramAudioPlayer> createState() => _InstagramAudioPlayerState();
}

class _InstagramAudioPlayerState extends State<InstagramAudioPlayer> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    AudioPlayerService.initialize();
    
    // Create subtle pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to playing state
    AudioPlayerService.isPlayingNotifier.addListener(_handlePlayingStateChange);
  }

  void _handlePlayingStateChange() {
    if (AudioPlayerService.isUrlPlaying(widget.audioUrl)) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    AudioPlayerService.isPlayingNotifier.removeListener(_handlePlayingStateChange);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Audio waveform container
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.8),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Sound icon
                  Icon(
                    Icons.music_note,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  // Progress visualization
                  Expanded(
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: AudioPlayerService.positionNotifier,
                      builder: (context, position, child) {
                        return ValueListenableBuilder<Duration>(
                          valueListenable: AudioPlayerService.durationNotifier,
                          builder: (context, duration, child) {
                            final isCurrentAudio = AudioPlayerService.currentUrl == widget.audioUrl;
                            final currentPosition = isCurrentAudio ? position : Duration.zero;
                            final totalDuration = isCurrentAudio ? duration : Duration.zero;
                            
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Background waveform
                                CustomPaint(
                                  painter: SimpleWaveformPainter(
                                    progress: totalDuration.inMilliseconds > 0
                                        ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
                                        : 0.0,
                                    isPlaying: AudioPlayerService.isUrlPlaying(widget.audioUrl),
                                  ),
                                  child: Container(height: 20),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Duration text
                  ValueListenableBuilder<Duration>(
                    valueListenable: AudioPlayerService.durationNotifier,
                    builder: (context, duration, child) {
                      final isCurrentAudio = AudioPlayerService.currentUrl == widget.audioUrl;
                      final totalDuration = isCurrentAudio ? duration : Duration.zero;
                      
                      return Text(
                        _formatDuration(totalDuration),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Play/Pause button
          ValueListenableBuilder<bool>(
            valueListenable: AudioPlayerService.isPlayingNotifier,
            builder: (context, isPlaying, child) {
              final isCurrentlyPlaying = AudioPlayerService.isUrlPlaying(widget.audioUrl);
              
              return AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isCurrentlyPlaying ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: () async {
                        if (isCurrentlyPlaying) {
                          await AudioPlayerService.pause();
                        } else {
                          await AudioPlayerService.playFromUrl(widget.audioUrl);
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrentlyPlaying ? Colors.white : Colors.grey[300],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds == 0) return "0:00";
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    return "${duration.inMinutes}:$twoDigitSeconds";
  }
}

// Simple waveform painter for Instagram-style visualization
class SimpleWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  SimpleWaveformPainter({
    required this.progress,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint inactivePaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final Paint activePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Create simple vertical bars
    final double barWidth = 2;
    final double spacing = 3;
    final int barCount = (size.width / (barWidth + spacing)).floor();
    
    for (int i = 0; i < barCount; i++) {
      final double x = i * (barWidth + spacing);
      
      // Vary heights for visual interest
      final double heightMultiplier = (i % 4 == 0) ? 0.8 : 
                                    (i % 3 == 0) ? 0.6 : 
                                    (i % 2 == 0) ? 0.4 : 0.3;
      final double height = size.height * heightMultiplier;
      final double y = (size.height - height) / 2;
      
      // Determine if this bar should be active
      final bool isActiveBar = (x / size.width) <= progress;
      
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + height),
        isActiveBar ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

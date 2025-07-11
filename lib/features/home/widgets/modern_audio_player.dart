import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class ModernAudioPlayer extends StatefulWidget {
  const ModernAudioPlayer({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<ModernAudioPlayer> createState() => _ModernAudioPlayerState();
}

class _ModernAudioPlayerState extends State<ModernAudioPlayer> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    AudioPlayerService.initialize();
    
    // Create animation for the pulsing effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start pulsing animation when playing
    AudioPlayerService.isPlayingNotifier.addListener(_handlePlayingStateChange);
  }

  void _handlePlayingStateChange() {
    if (AudioPlayerService.isUrlPlaying(widget.audioUrl)) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    AudioPlayerService.isPlayingNotifier.removeListener(_handlePlayingStateChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Audio waveform visualization (static for now)
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.graphic_eq,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
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
                            
                            return CustomPaint(
                              painter: AudioWaveformPainter(
                                progress: totalDuration.inMilliseconds > 0
                                    ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
                                    : 0.0,
                                isPlaying: AudioPlayerService.isUrlPlaying(widget.audioUrl),
                              ),
                              child: Container(height: 24),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<Duration>(
                    valueListenable: AudioPlayerService.durationNotifier,
                    builder: (context, duration, child) {
                      final isCurrentAudio = AudioPlayerService.currentUrl == widget.audioUrl;
                      final totalDuration = isCurrentAudio ? duration : Duration.zero;
                      
                      return Text(
                        _formatDuration(totalDuration),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
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
          // Play/Pause button with animation
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
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isCurrentlyPlaying
                                ? [Colors.purple, Colors.blue]
                                : [Colors.grey[700]!, Colors.grey[800]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: isCurrentlyPlaying
                              ? [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
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
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${duration.inMinutes}:$twoDigitSeconds";
    }
  }
}

// Custom painter for audio waveform visualization
class AudioWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  AudioWaveformPainter({
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
      ..shader = LinearGradient(
        colors: isPlaying
            ? [Colors.purple, Colors.blue]
            : [Colors.grey[400]!, Colors.grey[500]!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Create a simple waveform pattern
    final double barWidth = 3;
    final double spacing = 2;
    final int barCount = (size.width / (barWidth + spacing)).floor();
    
    for (int i = 0; i < barCount; i++) {
      final double x = i * (barWidth + spacing);
      final double height = (i % 3 == 0) ? size.height * 0.8 : 
                           (i % 2 == 0) ? size.height * 0.6 : size.height * 0.4;
      
      final double y = (size.height - height) / 2;
      
      // Determine if this bar should be active based on progress
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

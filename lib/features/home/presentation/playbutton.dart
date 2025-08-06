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

class _PlaybuttonState extends State<Playbutton> with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize audio player service
    AudioPlayerService.initialize();
    
    // Initialize wave animation
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start repeating animation
    _waveAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    super.dispose();
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
        vertical: 5,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: ValueListenableBuilder<bool>(
          valueListenable: AudioPlayerService.isPlayingNotifier,
          builder: (context, isPlaying, child) {
            final isCurrentlyPlaying = AudioPlayerService.isUrlPlaying(widget.audioUrl!);
            
            return GestureDetector(
              onTap: () async {
                if (isCurrentlyPlaying) {
                  await AudioPlayerService.pause();
                } else {
                  await AudioPlayerService.playFromUrl(widget.audioUrl!);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated play/pause icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(isCurrentlyPlaying),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          isCurrentlyPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black87,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Audio wave animation when playing
                    if (isCurrentlyPlaying) ...[
                      _buildWaveAnimation(),
                      const SizedBox(width: 8),
                    ],
                    // Play/Pause text
                    Text(
                      isCurrentlyPlaying ? "Now Playing" : "Audio",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
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

  // Animated wave visualization for when audio is playing
  Widget _buildWaveAnimation() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 8 + (4 * _waveAnimation.value) + (index * 2),
              width: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      },
    );
  }
}

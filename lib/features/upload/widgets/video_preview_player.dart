import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

/// A widget that plays video and provides Instagram-like controls
class VideoPreviewPlayer extends StatefulWidget {
  final File videoFile;
  final bool autoPlay;
  final bool showControls;
  final bool looping;
  
  const VideoPreviewPlayer({
    Key? key,
    required this.videoFile,
    this.autoPlay = false,
    this.showControls = true,
    this.looping = true,
  }) : super(key: key);

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isControlsVisible = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }
  
  Future<void> _initializeVideoPlayer() async {
    try {
      debugPrint('VideoPreviewPlayer: Initializing with file: ${widget.videoFile.path}');
      debugPrint('VideoPreviewPlayer: File exists: ${widget.videoFile.existsSync()}');
      
      // Make sure the file exists and has content
      if (!widget.videoFile.existsSync() || await widget.videoFile.length() == 0) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video file is invalid or empty';
        });
        debugPrint('VideoPreviewPlayer: File invalid or empty');
        return;
      }
      
      _controller = VideoPlayerController.file(widget.videoFile);
      
      // Set up controller options
      _controller.setLooping(widget.looping);
      
      // Set a timeout to prevent infinite loading
      bool initializationTimedOut = false;
      Future.delayed(const Duration(seconds: 10), () {
        if (!_isInitialized && mounted && !_hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video initialization timed out';
          });
          initializationTimedOut = true;
          debugPrint('VideoPreviewPlayer: Initialization timed out');
        }
      });
      
      await _controller.initialize().then((_) {
        if (mounted && !initializationTimedOut) {
          setState(() {
            _isInitialized = true;
            // Auto play if specified
            if (widget.autoPlay) {
              _controller.play();
              _isPlaying = true;
            }
          });
          debugPrint('VideoPreviewPlayer: Successfully initialized');
          
          // Auto-hide controls after delay
          if (_isPlaying && widget.showControls) {
            setState(() {
              _isControlsVisible = true;
            });
            
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _isPlaying) {
                setState(() {
                  _isControlsVisible = false;
                });
              }
            });
          }
        }
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (mounted && !_isInitialized) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Video initialization timed out';
            });
            debugPrint('VideoPreviewPlayer: Initialization timeout');
          }
          return null;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize video: $e';
        });
      }
      debugPrint('VideoPreviewPlayer Error: $e');
    }
  }
  
  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  // Toggle controls visibility
  void _toggleControls() {
    if (!widget.showControls) return;
    
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    // Auto-hide controls after delay if video is playing
    if (_isControlsVisible && _isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _isControlsVisible = false;
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Show error state
    if (_hasError) {
      return _buildErrorView();
    }
    
    // Show loading state
    if (!_isInitialized) {
      return _buildLoadingView();
    }
    
    // Show video player
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video display - use a Container to enforce the size
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          
          // Instagram-like controls - only show when _isControlsVisible is true
          if (_isControlsVisible && widget.showControls)
            _buildVideoControls(),
          
          // Video progress indicator at bottom - always visible
          if (widget.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                colors: VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.white.withOpacity(0.5),
                  backgroundColor: Colors.grey.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Instagram-like video controls overlay
  Widget _buildVideoControls() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Stack(
        children: [
          // Play/pause button in center
          Center(
            child: IconButton(
              iconSize: 70,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.white.withOpacity(0.9),
              ),
              onPressed: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  setState(() {
                    _isPlaying = false;
                  });
                } else {
                  _controller.play();
                  setState(() {
                    _isPlaying = true;
                    
                    // Auto-hide controls after delay
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted && _isPlaying) {
                        setState(() {
                          _isControlsVisible = false;
                        });
                      }
                    });
                  });
                }
              },
            ),
          ),
          
          // Volume control
          Positioned(
            right: 16,
            bottom: 16,
            child: IconButton(
              icon: const Icon(
                Icons.volume_up,
                color: Colors.white,
              ),
              onPressed: () {
                // Toggle mute/unmute
                if (_controller.value.volume > 0) {
                  _controller.setVolume(0);
                } else {
                  _controller.setVolume(1.0);
                }
                setState(() {}); // Refresh UI
              },
            ),
          ),
          
          // Time indicator
          Positioned(
            left: 16,
            bottom: 16,
            child: _buildTimeIndicator(),
          ),
        ],
      ),
    );
  }
  
  // Time indicator showing current position and total duration
  Widget _buildTimeIndicator() {
    final String position = _formatDuration(_controller.value.position);
    final String duration = _formatDuration(_controller.value.duration);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$position / $duration',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Instagram-like loading view
  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Preparing video...',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
  
  // Instagram-like error view
  Widget _buildErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 12),
            Text(
              'Unable to play video',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                });
                _initializeVideoPlayer();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Format duration into Instagram-style time string
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    return '$minutes:$seconds';
  }
}

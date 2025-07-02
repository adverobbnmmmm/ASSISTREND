import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A widget that plays videos from network URLs with Instagram-like controls
class NetworkVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final bool looping;
  
  const NetworkVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.looping = true,
  }) : super(key: key);

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
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
      debugPrint('NetworkVideoPlayer: Initializing with URL: ${widget.videoUrl}');
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      // Set up controller options
      _controller.setLooping(widget.looping);
      
      // Set a timeout to prevent infinite loading
      bool initializationTimedOut = false;
      Future.delayed(const Duration(seconds: 15), () {
        if (!_isInitialized && mounted && !_hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video initialization timed out';
          });
          initializationTimedOut = true;
          debugPrint('NetworkVideoPlayer: Initialization timed out');
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
          debugPrint('NetworkVideoPlayer: Successfully initialized');
          
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
        const Duration(seconds: 15),
        onTimeout: () {
          if (mounted && !_isInitialized) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Video initialization timed out';
            });
            debugPrint('NetworkVideoPlayer: Initialization timeout');
          }
          return null;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video: $e';
        });
      }
      debugPrint('NetworkVideoPlayer Error: $e');
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
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video display
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
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
      ),
    );
  }
  
  // Instagram-like video controls overlay
  Widget _buildVideoControls() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
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
              'Loading video...',
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
}

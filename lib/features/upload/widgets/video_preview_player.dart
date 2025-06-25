import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

/// A widget that plays video and provides basic controls
class VideoPreviewPlayer extends StatefulWidget {
  final File videoFile;
  
  const VideoPreviewPlayer({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
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
          });
          debugPrint('VideoPreviewPlayer: Successfully initialized');
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
  
  @override
  Widget build(BuildContext context) {
    // Show error state
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            const SizedBox(height: 12),
            Text(
              'Unable to load video',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Show loading state
    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      );
    }
    
    // Show video player
    return Stack(
      alignment: Alignment.center,
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
        
        // Play/pause button
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            size: 64,
            color: Colors.white.withOpacity(0.8),
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
              });
            }
          },
        ),
        
        // Video progress indicator at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            colors: VideoProgressColors(
              playedColor: Theme.of(context).primaryColor,
              bufferedColor: Colors.white.withOpacity(0.5),
              backgroundColor: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

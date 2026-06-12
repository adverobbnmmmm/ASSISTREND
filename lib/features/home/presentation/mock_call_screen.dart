import 'dart:async';
import 'package:flutter/material.dart';

class MockCallScreen extends StatefulWidget {
  final String userName;
  final String userEmoji;
  final String userLocation;

  const MockCallScreen({
    super.key,
    required this.userName,
    required this.userEmoji,
    this.userLocation = 'Remote',
  });

  @override
  State<MockCallScreen> createState() => _MockCallScreenState();
}

class _MockCallScreenState extends State<MockCallScreen> {
  String _callState = 'Connecting...';
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    // Simulate connection flow:
    // Connecting... (1.5s) -> Ringing... (2s) -> Active Call
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _callState = 'Ringing...';
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _callState = 'Active Call';
        });
        _startTimer();
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1216),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Avatar/Emoji
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D5EFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1D5EFF).withOpacity(0.3),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.userEmoji.isNotEmpty ? widget.userEmoji : '👤',
                    style: const TextStyle(fontSize: 70),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // User name
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Location / Specialized Domain
            Text(
              widget.userLocation,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // Call State / Timer
            Text(
              _callState == 'Active Call' ? _formatDuration(_secondsElapsed) : _callState,
              style: TextStyle(
                color: _callState == 'Active Call' ? const Color(0xFF1D5EFF) : Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(flex: 3),
            // Call control buttons (Mute, Speaker, Keypad)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallActionButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: 'Mute',
                    isSelected: _isMuted,
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                  _CallActionButton(
                    icon: Icons.grid_on,
                    label: 'Keypad',
                    isSelected: false,
                    onPressed: () {},
                  ),
                  _CallActionButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    isSelected: _isSpeakerOn,
                    onPressed: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // End Call Button
            Center(
              child: FloatingActionButton(
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.call_end, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: isSelected ? Colors.white : Colors.white12,
            foregroundColor: isSelected ? Colors.black : Colors.white,
            padding: const EdgeInsets.all(16),
          ),
          icon: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

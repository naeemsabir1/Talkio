import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui';

enum PlaybackSpeed {
  learner,
  real,
  challenge,
}

class StickyAudioPlayer extends StatefulWidget {
  final String audioUrl;
  
  const StickyAudioPlayer({
    super.key,
    required this.audioUrl,
  });

  @override
  State<StickyAudioPlayer> createState() => _StickyAudioPlayerState();
}

class _StickyAudioPlayerState extends State<StickyAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  PlaybackSpeed _currentSpeed = PlaybackSpeed.real;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    
    // Listen to duration
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });
    
    // Listen to position
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
    
    // Load the audio source
    await _loadAudio();
  }

  Future<void> _loadAudio() async {
    if (widget.audioUrl.isEmpty) {
      debugPrint('⚠️ StickyAudioPlayer: audioUrl is empty, skipping load');
      return;
    }
    try {
      debugPrint('🔊 StickyAudioPlayer: Loading audio from ${widget.audioUrl}');
      if (widget.audioUrl.startsWith('http')) {
        await _audioPlayer.setUrl(widget.audioUrl);
      } else {
        await _audioPlayer.setFilePath(widget.audioUrl);
      }
      debugPrint('✅ StickyAudioPlayer: Audio loaded successfully');
    } catch (e) {
      debugPrint('❌ StickyAudioPlayer: Error loading audio: $e');
    }
  }

  @override
  void didUpdateWidget(covariant StickyAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _loadAudio();
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _cycleSpeed() {
    setState(() {
      switch (_currentSpeed) {
        case PlaybackSpeed.learner:
          _currentSpeed = PlaybackSpeed.real;
          _audioPlayer.setSpeed(1.0);
          break;
        case PlaybackSpeed.real:
          _currentSpeed = PlaybackSpeed.challenge;
          _audioPlayer.setSpeed(1.5);
          break;
        case PlaybackSpeed.challenge:
          _currentSpeed = PlaybackSpeed.learner;
          _audioPlayer.setSpeed(0.75);
          break;
      }
    });
  }

  String _getSpeedLabel() {
    switch (_currentSpeed) {
      case PlaybackSpeed.learner:
        return '🐢 0.75x Learner';
      case PlaybackSpeed.real:
        return '🎧 1.0x Real';
      case PlaybackSpeed.challenge:
        return '⚡ 1.5x Challenge';
    }
  }

  Color _getSpeedColor() {
    switch (_currentSpeed) {
      case PlaybackSpeed.learner:
        return const Color(0xFF10B981); // Green
      case PlaybackSpeed.real:
        return const Color(0xFF3B82F6); // Blue
      case PlaybackSpeed.challenge:
        return const Color(0xFFEF4444); // Red
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Play/Pause button
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    onTap: _togglePlayPause,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Progress and info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: _position.inMilliseconds.toDouble(),
                          max: _duration.inMilliseconds.toDouble() > 0
                              ? _duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (value) {
                            _audioPlayer.seek(
                              Duration(milliseconds: value.toInt()),
                            );
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Colors.grey[300],
                        ),
                      ),
                      
                      // Time display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Speed toggle button
                Material(
                  color: _getSpeedColor(),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 2,
                  child: InkWell(
                    onTap: _cycleSpeed,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        _getSpeedLabel(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

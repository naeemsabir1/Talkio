import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auraly_clone/core/services/ai_content_service.dart';
import 'package:auraly_clone/core/providers/memo_provider.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String sharedUrl;
  final String selectedLanguage;

  const ProcessingScreen({
    super.key,
    required this.sharedUrl,
    required this.selectedLanguage,
  });

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  int _statusIndex = 0;
  bool _keepCycling = true;
  final List<String> _statusMessages = [
    "Extracting Audio...",
    "Transcribing Speech...",
    "Analyzing Grammar...",
    "Generating Summary...",
    "Finalizing Lesson..."
  ];

  @override
  void initState() {
    super.initState();
    _startProcessing();
    _cycleStatus();
  }

  void _cycleStatus() async {
    // Keep cycling through status messages until processing is done
    while (_keepCycling && mounted) {
      for (int i = 0; i < _statusMessages.length; i++) {
        if (!mounted || !_keepCycling) return;
        setState(() => _statusIndex = i);
        await Future.delayed(const Duration(milliseconds: 2500));
      }
    }
  }

  Future<void> _startProcessing() async {
    try {
      // 1. Call the REAL AI backend
      final service = ref.read(aiContentServiceProvider);
      final memo = await service.processUrl(widget.sharedUrl, widget.selectedLanguage, 'English');
      
      if (!mounted) return;
      _keepCycling = false;

      // 2. Save memo to global state so it appears in Recent Memos
      final currentMemos = ref.read(memosProvider);
      ref.read(memosProvider.notifier).state = [
        memo,
        ...currentMemos,
      ];

      // 3. Navigate to Detail Screen
      context.go('/memo/${memo.id}', extra: memo);
    } on AiServiceException catch (e) {
      if (!mounted) return;
      _keepCycling = false;
      _showErrorDialog(e.message);
    } catch (e) {
      if (!mounted) return;
      _keepCycling = false;
      _showErrorDialog(
        'Cannot reach the AI server. Make sure the backend is running on port 8000.',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 12),
            Text('Processing Failed', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Go Back', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _keepCycling = true;
                _statusIndex = 0;
              });
              _startProcessing();
              _cycleStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // Dark Slate
              Color(0xFF172554), // Deep Blue to match screenshot
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo (Optional, based on screenshot)
              const Text(
                'auraly',
                style: TextStyle(
                  fontFamily: 'Inter', 
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3B82F6), // Talkio Blue
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 80),

              // Progress Circle
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Circle
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      color: Colors.white.withOpacity(0.05),
                    ),
                    // Animated Foreground Circle
                     TweenAnimationBuilder<double>(
                       tween: Tween(begin: 0.0, end: 1.0),
                       duration: const Duration(seconds: 4),
                       builder: (context, value, child) {
                         // Spin and fill effect
                         return CircularProgressIndicator(
                           value: value, // 0 to 1
                           strokeWidth: 12,
                           valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                           backgroundColor: Colors.transparent,
                           strokeCap: StrokeCap.round,
                         );
                       },
                     ),
                    
                    // Percentage Text
                    Center(
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: 100),
                        duration: const Duration(seconds: 4),
                        builder: (context, value, child) {
                          return Text(
                            '$value%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Status Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _statusMessages[_statusIndex],
                  key: ValueKey<int>(_statusIndex),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

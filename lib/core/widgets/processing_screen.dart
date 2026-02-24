import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/ai_content_service.dart';
import '../models/memo_model.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String? sourceUrl;
  final String language;
  final String targetLanguage;

  const ProcessingScreen({
    super.key,
    this.sourceUrl,
    required this.language,
    required this.targetLanguage,
  });

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  int _progress = 0;
  String _statusText = 'Connecting...';
  Timer? _timer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    if (_isProcessing) return;
    _isProcessing = true;

    // Fake progress timer for visual feedback
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_progress < 90) {
          _progress += 1;
          
          if (_progress < 30) {
            _statusText = 'Connecting to source...';
          } else if (_progress < 60) {
            _statusText = 'Extracting audio & text...';
          } else {
            _statusText = 'Analyzing grammar & vocab...';
          }
        }
      });
    });

    try {
      if (widget.sourceUrl == null || widget.sourceUrl!.isEmpty) {
        throw Exception("Invalid URL");
      }

      // Call the actual API
      final memo = await ref.read(aiContentServiceProvider).processUrl(
        widget.sourceUrl!,
        widget.language,
        widget.targetLanguage,
      );

      // Success!
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _progress = 100;
          _statusText = 'Ready!';
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pop(context, memo); // Return the Memo object
        }
      }

    } catch (e) {
       _timer?.cancel();
       if (mounted) {
         setState(() {
           _statusText = 'Error: ${e.toString()}';
           _progress = 0;
         });
         
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed: ${e.toString()}')),
         );
         
         await Future.delayed(const Duration(seconds: 2));
         if (mounted) {
           Navigator.pop(context, null);
         }
       }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect source from URL
    String source = 'Source';
    if (widget.sourceUrl != null) {
      if (widget.sourceUrl!.contains('instagram')) {
        source = 'Instagram';
      } else if (widget.sourceUrl!.contains('tiktok')) {
        source = 'TikTok';
      } else if (widget.sourceUrl!.contains('youtube') || widget.sourceUrl!.contains('youtu.be')) {
        source = 'YouTube';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress with percentage
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: _progress / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                Text(
                  '$_progress%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Status text
            Text(
              'Importing from $source...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Sub-status text with animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _statusText,
                key: ValueKey(_statusText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

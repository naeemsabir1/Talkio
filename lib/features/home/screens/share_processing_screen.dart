import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:ui';
import '../../../core/services/ai_content_service.dart';
import '../../../core/models/memo_model.dart';
import '../../memo/screens/memo_detail_screen.dart';
import '../widgets/language_picker_sheet.dart';

class ShareProcessingScreen extends StatefulWidget {
  final String sharedUrl;
  
  const ShareProcessingScreen({super.key, required this.sharedUrl});

  @override
  State<ShareProcessingScreen> createState() => _ShareProcessingScreenState();
}

class _ShareProcessingScreenState extends State<ShareProcessingScreen> {
  String? _selectedLanguage;
  bool _isProcessing = false;
  bool _showResults = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _progress = 0.0;
  int _statusIndex = 0;
  Memo? _resultMemo;
  
  // Audio Player State
  // final AudioPlayer _audioPlayer = AudioPlayer(); // Removed unused
  // bool _isPlaying = false; // Removed unused
  // int _speedState = 1; // Removed unused
  // double _playbackSpeed = 1.0; // Removed unused
  // Duration _duration = const Duration(seconds: 32); // Removed unused
  // Duration _position = Duration.zero; // Removed unused
  
  final List<String> _statusMessages = [
    "Importing from Instagram...",
    "Extracting Audio...",
    "Transcribing Speech...",
    "Analyzing Grammar...",
    "Finalizing Memo..."
  ];

  @override
  void initState() {
    super.initState();
    // Show language picker immediately after route transition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _showLanguagePicker();
      });
    });
    // Audio init removed
  }



  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _buildLanguageSheet(),
    ).then((language) {
      if (language != null) {
        setState(() {
          _selectedLanguage = language;
          _isProcessing = true;
        });
        print('✅ Language selected: $language');
        _startProcessing();
      } else {
        // User cancelled, close screen
        Navigator.pop(context);
      }
    });
  }

  Future<void> _startProcessing() async {
    // Animate progress (runs in parallel)
    _animateProgress();
    _cycleStatus();
    
    try {
      // Call the REAL AI backend
      final service = AiContentService();
      final memo = await service.processUrl(
        widget.sharedUrl,
        'auto',  // Source: auto-detect by Whisper
        _selectedLanguage ?? 'English',  // Target: user's chosen language
      );
      
      if (!mounted) return;
      
      // Save memo reference
      _resultMemo = memo;
      
      // Save to shared prefs for recent memos list

      
      // Show results with real data
      setState(() {
        _isProcessing = false;
        _showResults = true;
      });

    } on AiServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = 'Cannot reach the AI server. Make sure the backend is running.';
      });
    }
  }

  void _animateProgress() async {
    for (int i = 0; i <= 100; i++) {
      if (!mounted || !_isProcessing) return;
      setState(() => _progress = i / 100);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _cycleStatus() async {
    for (int i = 0; i < _statusMessages.length; i++) {
      if (!mounted || !_isProcessing) return;
      setState(() => _statusIndex = i);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return _buildProcessingView();
    } else if (_hasError) {
      return _buildErrorView();
    } else if (_showResults) {
      return _buildResultsView();
    } else {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }

  Widget _buildErrorView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 64),
              const SizedBox(height: 24),
              const Text(
                'Processing Failed',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isProcessing = true;
                        _progress = 0.0;
                        _statusIndex = 0;
                      });
                      _startProcessing();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED), // Violet
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Retry', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSheet() {
    return LanguagePickerSheet(
      currentLanguage: 'English',
      onLanguageSelected: (lang) {
        // LanguagePickerSheet._handleSelection already pops with this value
        // The value is received by showModalBottomSheet.then((language) => ...)
      },
    );
  }


  Widget _buildProcessingView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF2E1065)], // Slate 900 -> Deep Violet
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Talkio',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C3AED), // Violet
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 100),
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)), // Violet
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${(_progress * 100).toInt()}%',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusMessages[_statusIndex],
                  key: ValueKey<int>(_statusIndex),
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_resultMemo == null) return const SizedBox.shrink();
    return MemoDetailScreen(
      memo: _resultMemo!, 
      isPreview: true, // Enable Save/Quit mode for new memos
    );
  }


}

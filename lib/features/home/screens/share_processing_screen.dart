import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/ai_content_service.dart';
import '../../../core/models/memo_model.dart';
import '../../memo/screens/memo_detail_screen.dart';
import '../widgets/language_picker_sheet.dart';

class ShareProcessingScreen extends StatefulWidget {
  final String sharedUrl;
  final String? initialLanguage;
  
  const ShareProcessingScreen({
    super.key, 
    required this.sharedUrl,
    this.initialLanguage,
  });

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
    "Importing...",
    "Extracting Audio...",
    "Transcribing Speech...",
    "Analyzing Grammar...",
    "Finalizing Memo..."
  ];

  @override
  void initState() {
    super.initState();
    // Use initialLanguage if provided (manual flow), otherwise show picker (share intent)
    if (widget.initialLanguage != null) {
      _selectedLanguage = widget.initialLanguage;
      _isProcessing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startProcessing();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _showLanguagePicker();
        });
      });
    }
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
    try {
      final service = AiContentService();
      
      // Step 1: Extraction & Transcription
      if (!mounted) return;
      setState(() {
        _progress = 0.2;
        _statusIndex = 0; // "Importing from Instagram..."
      });
      
      var memo = await service.processUrl(
        widget.sharedUrl,
        'auto',  
        _selectedLanguage ?? 'English',  
        context.locale.languageCode, // Pass App UI Language
      );
      
      // Step 2: AI Copyediting
      if (!mounted) return;
      setState(() {
        _progress = 0.5;
        _statusIndex = 2; // "Transcribing Speech..."
      });
      
      try {
        if (memo.words.isNotEmpty) {
          final rawString = memo.words.map((w) => w.word).join(" ");
          final formattedString = await service.formatTranscriptionWithAI(rawString);
          final formattedTokens = formattedString.split(RegExp(r'\s+'));
          
          final updatedWords = <WordTimestamp>[];
          int tIndex = 0;
          for (int i = 0; i < memo.words.length; i++) {
            final orig = memo.words[i];
            if (tIndex < formattedTokens.length) {
               updatedWords.add(WordTimestamp(word: formattedTokens[tIndex], start: orig.start, end: orig.end));
               tIndex++;
            } else {
               updatedWords.add(orig);
            }
          }

          final updatedSegments = <TranscriptSegment>[];
          for (int i = 0; i < memo.transcript.length; i++) {
            final seg = memo.transcript[i];
            final nextSegTime = (i + 1 < memo.transcript.length) ? memo.transcript[i + 1].timestamp : double.maxFinite;
            final segWords = updatedWords.where((w) => w.start >= seg.timestamp && w.start < nextSegTime).map((w) => w.word).join(" ");
            updatedSegments.add(TranscriptSegment(original: segWords.isNotEmpty ? segWords : seg.original, translation: seg.translation, timestamp: seg.timestamp));
          }

          memo = Memo(
            id: memo.id, title: memo.title, sourceUrl: memo.sourceUrl, sourcePlatform: memo.sourcePlatform,
            thumbnailUrl: memo.thumbnailUrl, date: memo.date, 
            language: _selectedLanguage ?? memo.language, // Fix Language Regression
            summary: memo.summary,
            audioUrl: memo.audioUrl, transcript: updatedSegments, vocabulary: memo.vocabulary, grammar: memo.grammar,
            conjugations: memo.conjugations, words: updatedWords, quiz: memo.quiz,
          );
        }
      } catch (e) {
        debugPrint('Copyedit failed, keeping raw: $e');
      }
      
      // Step 3: Download Cover Image
      if (!mounted) return;
      setState(() {
        _progress = 0.8;
        _statusIndex = 4; // "Finalizing Memo..."
      });
      
      try {
        String finalAudioUrl = memo.audioUrl;
        final dir = await getApplicationDocumentsDirectory();
        
        // Cache Cover Image Locally
        if (memo.thumbnailUrl.startsWith('http')) {
          final imageFile = File('${dir.path}/image_${memo.id}.jpg');
          final response = await http.get(Uri.parse(memo.thumbnailUrl));
          await imageFile.writeAsBytes(response.bodyBytes);
          
          memo = Memo(
            id: memo.id, title: memo.title, sourceUrl: memo.sourceUrl, sourcePlatform: memo.sourcePlatform,
            thumbnailUrl: imageFile.path, date: memo.date, language: memo.language, summary: memo.summary,
            audioUrl: memo.audioUrl, transcript: memo.transcript, vocabulary: memo.vocabulary, grammar: memo.grammar,
            conjugations: memo.conjugations, words: memo.words, quiz: memo.quiz,
          );
        }

        // Cache TTS Audio Locally
        // Skip if audioUrl is empty (TTS generation failed on backend)
        if (memo.audioUrl.isNotEmpty && memo.audioUrl.startsWith('http')) {
           try {
             debugPrint('🔊 Downloading TTS audio from: ${memo.audioUrl}');
             final audioFile = File('${dir.path}/audio_${memo.id}.mp3');
             final response = await http.get(Uri.parse(memo.audioUrl))
                 .timeout(const Duration(seconds: 60));
             if (response.statusCode == 200 && response.bodyBytes.length > 100) {
               await audioFile.writeAsBytes(response.bodyBytes);
               // Verify the file was written and has reasonable size
               if (await audioFile.exists() && await audioFile.length() > 100) {
                 finalAudioUrl = audioFile.path;
                 debugPrint('✅ TTS audio cached locally: ${audioFile.path} (${response.bodyBytes.length} bytes)');
               } else {
                 debugPrint('⚠️ TTS audio file validation failed, using remote URL as fallback');
               }
             } else {
               debugPrint('⚠️ TTS audio download returned status ${response.statusCode} or empty body, using remote URL as fallback');
             }
           } catch (e) {
             debugPrint('⚠️ Failed to download TTS audio: $e — will use remote URL as fallback');
             // Keep the remote URL — just_audio can stream it directly
           }
        } else if (memo.audioUrl.isEmpty) {
          debugPrint('⚠️ audioUrl is empty (TTS failed on backend), skipping audio caching');
        }
          
        memo = Memo(
          id: memo.id, title: memo.title, sourceUrl: memo.sourceUrl, sourcePlatform: memo.sourcePlatform,
          thumbnailUrl: memo.thumbnailUrl,
          date: memo.date, 
          language: _selectedLanguage ?? memo.language, // Keep fixed language 
          summary: memo.summary, audioUrl: finalAudioUrl, // Use safely cached audio path
          transcript: memo.transcript, vocabulary: memo.vocabulary, grammar: memo.grammar,
          conjugations: memo.conjugations, words: memo.words, quiz: memo.quiz,
        );
      } catch (e) {
        debugPrint('Failed to download cover image: $e');
      }
      
      // Step 4: Completion
      if (!mounted) return;
      _resultMemo = memo;
      
      setState(() {
        _progress = 1.0;
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
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: _progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 10,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)), // Violet
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Text(
                                '${(value * 100).toInt()}%',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
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

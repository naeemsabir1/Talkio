import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui';
import '../../../core/models/memo_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/memo_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/karaoke_transcript_card.dart';
import '../widgets/translation_card.dart';
import '../widgets/vocabulary_card.dart';
import '../widgets/grammar_card.dart';
import '../widgets/pronouns_card.dart';
import '../widgets/conjugation_card.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/widgets/language_switcher.dart';
import 'package:easy_localization/easy_localization.dart';

class MemoDetailScreen extends ConsumerStatefulWidget {
  final Memo memo;
  final bool isPreview;

  const MemoDetailScreen({
    super.key, 
    required this.memo,
    this.isPreview = false,
  });

  @override
  ConsumerState<MemoDetailScreen> createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends ConsumerState<MemoDetailScreen> {

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  int _speedState = 1; // 0=0.75x, 1=1.0x, 2=1.5x

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    _audioPlayer.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });

    await _loadAudioUrl();
  }

  Future<void> _loadAudioUrl() async {
    if (widget.memo.audioUrl.isEmpty) {
      debugPrint('⚠️ MemoDetail: audioUrl is empty, skipping load');
      return;
    }
    try {
      debugPrint('🔊 MemoDetail: Loading audio from ${widget.memo.audioUrl}');
      
      // Check if it's a local file or a remote URL.
      // iOS requires setFilePath() for local files — setUrl() without
      // a file:// scheme prefix silently fails on iOS/AVFoundation.
      final isLocal = !widget.memo.audioUrl.startsWith('http');
      if (isLocal) {
        debugPrint('🔊 MemoDetail: Loading from local file via setFilePath');
        await _audioPlayer.setFilePath(widget.memo.audioUrl);
      } else {
        debugPrint('🔊 MemoDetail: Loading from remote URL');
        await _audioPlayer.setUrl(widget.memo.audioUrl);
      }
      debugPrint('✅ MemoDetail: Audio loaded — duration: ${_audioPlayer.duration}');
    } catch (e) {
      debugPrint('❌ MemoDetail: Error loading audio (attempt 1): $e');
      // Retry once after a short delay — iOS sometimes needs a moment
      // for the audio session to fully initialize
      await Future.delayed(const Duration(milliseconds: 800));
      try {
        final isLocal = !widget.memo.audioUrl.startsWith('http');
        if (isLocal) {
          await _audioPlayer.setFilePath(widget.memo.audioUrl);
        } else {
          await _audioPlayer.setUrl(widget.memo.audioUrl);
        }
        debugPrint('✅ MemoDetail: Audio loaded on retry — duration: ${_audioPlayer.duration}');
      } catch (retryError) {
        debugPrint('❌ MemoDetail: Audio load failed after retry: $retryError');
      }
    }
  }

  @override
  void didUpdateWidget(covariant MemoDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memo.audioUrl != widget.memo.audioUrl) {
      _loadAudioUrl();
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
      _speedState = (_speedState + 1) % 3;
      switch (_speedState) {
        case 0: _playbackSpeed = 0.75; break;
        case 1: _playbackSpeed = 1.0; break;
        case 2: _playbackSpeed = 1.5; break;
      }
      _audioPlayer.setSpeed(_playbackSpeed);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF60A5FA),
          surface: Color(0xFF1E293B),
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF020617)],
                ),
              ),
            ),

            // Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0).copyWith(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Summary
                        SummaryCard(summary: widget.memo.summary),

                        // 2. Transcript (Karaoke)
                        KaraokeTranscriptCard(
                          words: widget.memo.words,
                          segments: widget.memo.transcript,
                          currentPosition: _position,
                        ),

                        // 3. Translation (Conditional)
                        TranslationCard(segments: widget.memo.transcript),

                        // 4. Vocabulary
                        VocabularyCard(vocabulary: widget.memo.vocabulary),
                        
                        // 5. Pronouns (Split from Grammar)
                        PronounsCard(grammarPoints: widget.memo.grammar),

                        // 6. Grammar (General)
                        GrammarCard(grammarPoints: widget.memo.grammar),

                        // 7. Conjugation
                        ConjugationCard(conjugations: widget.memo.conjugations),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Player
            Positioned(
              left: 0, 
              right: 0, 
              bottom: 0, 
              child: _buildAudioPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF0F172A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [
        LanguageSwitcher(),
        SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.memo.thumbnailUrl.startsWith('http')
                ? Image.network(
                    widget.memo.thumbnailUrl,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  )
                : Image.file(
                    File(widget.memo.thumbnailUrl),
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0F172A).withOpacity(0.9),
                    const Color(0xFF0F172A),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      children: [
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language, color: Colors.white70, size: 12),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _getLanguageName(widget.memo.language),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.memo.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
        return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _buildAudioPlayer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.9),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: AppTheme.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                  max: _duration.inMilliseconds.toDouble(),
                  onChanged: (value) => _audioPlayer.seek(Duration(milliseconds: value.toInt())),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),

              // Controls
              if (widget.isPreview)
                _buildPreviewControls()
              else
                _buildStandardControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Speed
         GestureDetector(
            onTap: _cycleSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getSpeedColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getSpeedColor().withOpacity(0.5)),
              ),
              child: Text(
                _getSpeedLabel(),
                style: TextStyle(
                  color: _getSpeedColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
           Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow_rounded),
              color: Colors.white,
              iconSize: 32,
              onPressed: _togglePlayPause,
            ),
          ),
          const SizedBox(width: 80), // Balance the row
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Quit Button
        TextButton.icon(
          onPressed: _handleQuit,
          icon: const Icon(Icons.close, color: Colors.white70),
          label: Text('memo_detail.quit'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),

        // Play Button (Smaller)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow_rounded),
            color: Colors.white,
            onPressed: _togglePlayPause,
          ),
        ),

        // Save Button
        TextButton.icon(
          onPressed: _handleSave,
          icon: const Icon(Icons.check, color: Colors.white),
          label: Text('memo_detail.save'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF10B981), // Green
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            shadowColor: const Color(0xFF10B981).withOpacity(0.4),
            elevation: 8,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    // Check if audio exists and isn't already a local file
    Memo memoToSave = widget.memo;
    if (widget.memo.audioUrl.isNotEmpty && widget.memo.audioUrl.startsWith('http')) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final audioFile = File('${dir.path}/audio_${widget.memo.id}.mp3');
        final response = await http.get(Uri.parse(widget.memo.audioUrl));
        await audioFile.writeAsBytes(response.bodyBytes);
        
        memoToSave = Memo(
          id: widget.memo.id, title: widget.memo.title, sourceUrl: widget.memo.sourceUrl, sourcePlatform: widget.memo.sourcePlatform,
          thumbnailUrl: widget.memo.thumbnailUrl, date: widget.memo.date, language: widget.memo.language, summary: widget.memo.summary,
          audioUrl: audioFile.path, // Local path
          transcript: widget.memo.transcript, vocabulary: widget.memo.vocabulary, grammar: widget.memo.grammar,
          conjugations: widget.memo.conjugations, words: widget.memo.words, quiz: widget.memo.quiz,
        );
      } catch (e) {
        debugPrint('Failed to download audio file: $e');
      }
    }

    // Save to storage using Riverpod
    if (!mounted) return;
    ref.read(memosProvider.notifier).addMemo(memoToSave);
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('memo_detail.saved_library'.tr()),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );

    // Close screen (back to home) or switch to normal view?
    // User said "memo is stored in the app... showing"
    // So staying on the screen might be better, but "Quit" closes it.
    // If I save, I should probably go back to the list to show it's there, OR just switch mode.
    // Let's go back to home to be safe and consistent with "Quit" closing the flow.
    Navigator.pop(context);
  }

  void _handleQuit() {
    // Just close, data is discarded (since not saved)
    Navigator.pop(context);
  }

  String _getLanguageName(String l) {
    return l.toUpperCase();
  }

  String _getSpeedLabel() {
     switch (_speedState) {
       case 0: return '🐢 0.75x';
       case 1: return '🎧 1.0x';
       case 2: return '⚡ 1.5x';
       default: return '1.0x';
     }
  }

  Color _getSpeedColor() {
    switch (_speedState) {
      case 0: return const Color(0xFF10B981);
      case 1: return const Color(0xFF3B82F6);
      case 2: return const Color(0xFFEF4444);
       default: return Colors.white;
    }
  }
}

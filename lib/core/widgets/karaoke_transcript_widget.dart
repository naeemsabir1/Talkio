import 'package:flutter/material.dart';
import '../models/memo_model.dart';

/// A widget that displays transcript words with real-time karaoke highlighting.
///
/// As audio plays, the current word turns green while already-spoken words
/// show a muted green. Words not yet spoken remain white.
class KaraokeTranscriptWidget extends StatelessWidget {
  final List<WordTimestamp> words;
  final Duration currentPosition;
  final VoidCallback? onTapWord;

  const KaraokeTranscriptWidget({
    super.key,
    required this.words,
    required this.currentPosition,
    this.onTapWord,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Text(
          'No word-level data available.',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    final currentSec = currentPosition.inMilliseconds / 1000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Inter',
            height: 1.6,
          ),
          children: words.map((wordTs) {
            final state = _getWordState(wordTs, currentSec);
            
            Color textColor;
            FontWeight fontWeight;
            double fontSize;

            switch (state) {
              case _WordState.active:
                textColor = const Color(0xFF10B981); // Bright green
                fontWeight = FontWeight.w700;
                fontSize = 18;
                break;
              case _WordState.spoken:
                textColor = const Color(0xFF10B981).withOpacity(0.5); // Muted green
                fontWeight = FontWeight.w500;
                fontSize = 17;
                break;
              case _WordState.upcoming:
                textColor = Colors.white;
                fontWeight = FontWeight.w500;
                fontSize = 17;
                break;
            }

            return TextSpan(
              text: '${wordTs.word} ',
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  _WordState _getWordState(WordTimestamp word, double currentSec) {
    if (currentSec >= word.start && currentSec < word.end) {
      return _WordState.active; // Currently being spoken → bright green
    } else if (currentSec >= word.end) {
      return _WordState.spoken; // Already spoken → muted green
    } else {
      return _WordState.upcoming; // Not yet → white
    }
  }
}

enum _WordState { upcoming, active, spoken }


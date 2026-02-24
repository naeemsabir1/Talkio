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

    // Group words into lines/phrases (~10-12 words per line for readability)
    final phrases = _groupIntoPhrases(words, 10);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: phrases.map((phrase) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 5,
              runSpacing: 6,
              children: phrase.map((wordTs) {
                final wordState = _getWordState(wordTs, currentSec);
                return _KaraokeWord(
                  text: wordTs.word,
                  state: wordState,
                );
              }).toList(),
            ),
          );
        }).toList(),
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

  List<List<WordTimestamp>> _groupIntoPhrases(
      List<WordTimestamp> words, int maxWordsPerPhrase) {
    final phrases = <List<WordTimestamp>>[];
    var current = <WordTimestamp>[];

    for (final w in words) {
      current.add(w);

      // Break on sentence-ending punctuation or max words
      final endsWithPunctuation = w.word.endsWith('.') ||
          w.word.endsWith('!') ||
          w.word.endsWith('?') ||
          w.word.endsWith(',') ||
          w.word.endsWith(';');

      if (current.length >= maxWordsPerPhrase || endsWithPunctuation) {
        phrases.add(current);
        current = <WordTimestamp>[];
      }
    }

    if (current.isNotEmpty) {
      phrases.add(current);
    }

    return phrases;
  }
}

enum _WordState { upcoming, active, spoken }

class _KaraokeWord extends StatelessWidget {
  final String text;
  final _WordState state;

  const _KaraokeWord({required this.text, required this.state});

  @override
  Widget build(BuildContext context) {
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

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      style: TextStyle(
        color: textColor,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontFamily: 'Inter',
        height: 1.5,
      ),
      child: Text(text),
    );
  }
}

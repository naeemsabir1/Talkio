class Memo {
  final String id;
  final String title;
  final String sourceUrl;
  final String sourcePlatform;
  final String thumbnailUrl;
  final DateTime date;
  final String language; // Now a free-form string (e.g., "English", "Hindi")
  final String summary;
  final String audioUrl;
  final List<TranscriptSegment> transcript;
  final List<VocabularyItem> vocabulary;
  final List<GrammarPoint> grammar;
  final List<ConjugationItem> conjugations;
  final List<WordTimestamp> words;

  const Memo({
    required this.id,
    required this.title,
    required this.sourceUrl,
    required this.sourcePlatform,
    required this.thumbnailUrl,
    required this.date,
    required this.language,
    required this.summary,
    required this.audioUrl,
    required this.transcript,
    required this.vocabulary,
    required this.grammar,
    required this.conjugations,
    required this.words,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl,
      'sourcePlatform': sourcePlatform,
      'thumbnailUrl': thumbnailUrl,
      'date': date.toIso8601String(),
      'language': language,
      'summary': summary,
      'audioUrl': audioUrl,
      'transcript': transcript.map((x) => x.toJson()).toList(),
      'vocabulary': vocabulary.map((x) => x.toJson()).toList(),
      'grammar': grammar.map((x) => x.toJson()).toList(),
      'conjugations': conjugations.map((x) => x.toJson()).toList(),
      'words': words.map((x) => x.toJson()).toList(),
    };
  }

  factory Memo.fromJson(Map<String, dynamic> map) {
    // Handle both old enum-indexed format and new string format
    final langValue = map['language'];
    String language;
    if (langValue is int) {
      // Legacy: convert old enum index to name
      const legacyNames = [
        'English', 'Spanish', 'French', 'Chinese', 'German',
        'Japanese', 'Korean', 'Italian', 'Portuguese', 'Russian',
        'Arabic', 'Turkish',
      ];
      language = (langValue >= 0 && langValue < legacyNames.length)
          ? legacyNames[langValue]
          : 'English';
    } else {
      language = (langValue as String?) ?? 'English';
    }

    return Memo(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      sourceUrl: map['sourceUrl'] ?? '',
      sourcePlatform: map['sourcePlatform'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      date: DateTime.parse(map['date']),
      language: language,
      summary: map['summary'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      transcript: List<TranscriptSegment>.from(
          map['transcript']?.map((x) => TranscriptSegment.fromJson(x)) ?? []),
      vocabulary: List<VocabularyItem>.from(
          map['vocabulary']?.map((x) => VocabularyItem.fromJson(x)) ?? []),
      grammar: List<GrammarPoint>.from(
          map['grammar']?.map((x) => GrammarPoint.fromJson(x)) ?? []),
      conjugations: List<ConjugationItem>.from(
          map['conjugations']?.map((x) => ConjugationItem.fromJson(x)) ?? []),
      words: List<WordTimestamp>.from(
          map['words']?.map((x) => WordTimestamp.fromJson(x)) ?? []),
    );
  }
}

class WordTimestamp {
  final String word;
  final double start;
  final double end;

  const WordTimestamp({
    required this.word,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'start': start,
        'end': end,
      };

  factory WordTimestamp.fromJson(Map<String, dynamic> map) {
    return WordTimestamp(
      word: map['word'] ?? '',
      start: (map['start'] ?? 0).toDouble(),
      end: (map['end'] ?? 0).toDouble(),
    );
  }
}

class TranscriptSegment {
  final String original;
  final String translation;
  final double timestamp;

  const TranscriptSegment({
    required this.original,
    required this.translation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'original': original,
        'translation': translation,
        'timestamp': timestamp,
      };

  factory TranscriptSegment.fromJson(Map<String, dynamic> map) {
    return TranscriptSegment(
      original: map['original'] ?? '',
      translation: map['translation'] ?? '',
      timestamp: (map['timestamp'] ?? 0).toDouble(),
    );
  }
}

class VocabularyItem {
  final String word;
  final String pronunciation;
  final String definition;
  final String? example;

  const VocabularyItem({
    required this.word,
    required this.pronunciation,
    required this.definition,
    this.example,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'pronunciation': pronunciation,
        'definition': definition,
        'example': example,
      };

  factory VocabularyItem.fromJson(Map<String, dynamic> map) {
    return VocabularyItem(
      word: map['word'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      definition: map['definition'] ?? '',
      example: map['example'],
    );
  }
}

class GrammarPoint {
  final String type;
  final String title;
  final String explanation;
  final List<String> examples;

  const GrammarPoint({
    required this.type,
    required this.title,
    required this.explanation,
    required this.examples,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'explanation': explanation,
        'examples': examples,
      };

  factory GrammarPoint.fromJson(Map<String, dynamic> map) {
    return GrammarPoint(
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      explanation: map['explanation'] ?? '',
      examples: List<String>.from(map['examples'] ?? []),
    );
  }
}

class ConjugationItem {
  final String form;
  final String example;

  const ConjugationItem({
    required this.form,
    required this.example,
  });

  Map<String, dynamic> toJson() => {
        'form': form,
        'example': example,
      };

  factory ConjugationItem.fromJson(Map<String, dynamic> map) {
    return ConjugationItem(
      form: map['form'] ?? '',
      example: map['example'] ?? '',
    );
  }
}

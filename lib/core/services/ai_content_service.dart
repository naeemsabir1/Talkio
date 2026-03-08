import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/memo_model.dart';

/// Backend URL - change this for production deployment
// const String _backendBaseUrl = 'http://10.0.2.2:8000'; // Android emulator → localhost
// const String _backendBaseUrl = 'https://ef54712a9ae3f69d-72-255-7-228.serveousercontent.com'; // Old Serveo tunnel (dead)
// const String _backendBaseUrl = 'http://192.168.18.43:8000'; // Local LAN IP → laptop backend
const String _backendBaseUrl = 'https://talkio-production.up.railway.app'; // Railway Production
final aiContentServiceProvider = Provider<AiContentService>((ref) => AiContentService());

class AiContentService {
  /// Process a shared URL through the full AI pipeline.
  ///
  /// Calls the Python/FastAPI backend which:
  /// 1. Extracts audio from the URL (yt-dlp)
  /// 2. Transcribes with word-level timestamps (Whisper)
  /// 3. Generates educational content (GPT-4o)
  /// 4. Creates summary audio (TTS)
  ///
  /// Returns a fully populated [Memo] object.
  Future<Memo> processUrl(String url, String languageName, String targetLanguage, String appUiLanguage) async {
    final uri = Uri.parse('$_backendBaseUrl/api/process');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'url': url,
            'language': languageName,
            'target_language': targetLanguage,
            'app_ui_language': appUiLanguage,
          }),
        )
        .timeout(
          const Duration(minutes: 8), // Long videos (5-6 min) need up to 8 min for full pipeline
          onTimeout: () => throw AiServiceException(
            'Processing timed out. Longer videos may take up to 8 minutes. Please try again or use a shorter clip.',
          ),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResponseToMemo(data, url);
    } else if (response.statusCode == 400) {
      // Known validation error from backend
      final error = jsonDecode(response.body);
      throw AiServiceException(error['detail'] ?? 'Invalid request');
    } else {
      throw AiServiceException(
        'Server error (${response.statusCode}). Please try again later.',
      );
    }
  }

  /// Check if the backend server is reachable.
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse(_backendBaseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Parse JSON response into a Memo object matching our existing data model.
  Memo _parseResponseToMemo(Map<String, dynamic> data, String originalUrl) {
    // Parse language string to enum
    // Language is now a plain string — use as-is from backend
    final language = data['language'] as String? ?? 'English';

    // Parse transcript segments
    final transcriptList = (data['transcript'] as List<dynamic>?) ?? [];
    final transcript = transcriptList.map((t) {
      final map = t as Map<String, dynamic>;
      return TranscriptSegment(
        original: map['original'] as String? ?? '',
        translation: map['translation'] as String? ?? map['original'] as String? ?? '',
        timestamp: (map['timestamp'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    // Parse vocabulary
    final vocabList = (data['vocabulary'] as List<dynamic>?) ?? [];
    final vocabulary = vocabList.map((v) {
      final map = v as Map<String, dynamic>;
      return VocabularyItem(
        word: map['word'] as String? ?? '',
        pronunciation: map['pronunciation'] as String? ?? '',
        meaning: map['meaning'] as String? ?? map['definition'] as String? ?? '',
        explanation: map['explanation'] as String? ?? '',
        example: map['example'] as String?,
      );
    }).toList();

    // Parse grammar points (examples are now {sentence, translation} objects)
    final grammarList = (data['grammar'] as List<dynamic>?) ?? [];
    final grammar = grammarList.map((g) {
      final map = g as Map<String, dynamic>;
      return GrammarPoint(
        type: map['type'] as String? ?? 'General',
        title: map['title'] as String? ?? '',
        explanation: map['explanation'] as String? ?? '',
        examples: (map['examples'] as List<dynamic>?)
                ?.map((e) => GrammarExample.fromJson(e))
                .toList() ??
            [],
      );
    }).toList();

    // Parse pronouns from dedicated array and convert to GrammarPoint(type: 'Pronoun')
    // The backend returns pronouns separately with {category, word, explanation, examples[{sentence, translation}]}
    // We merge them into the grammar list so PronounsCard can find them via type == 'Pronoun'
    final pronounsList = (data['pronouns'] as List<dynamic>?) ?? [];
    for (final p in pronounsList) {
      final map = p as Map<String, dynamic>;
      final word = map['word'] as String? ?? '';
      final category = map['category'] as String? ?? '';
      final explanation = map['explanation'] as String? ?? '';
      final examplesRaw = (map['examples'] as List<dynamic>?) ?? [];
      final exampleObjects = examplesRaw.map((ex) {
        if (ex is Map<String, dynamic>) {
          return GrammarExample(
            sentence: ex['sentence'] as String? ?? '',
            translation: ex['translation'] as String? ?? '',
          );
        }
        return GrammarExample(sentence: ex.toString(), translation: '');
      }).toList();

      if (word.isNotEmpty || category.isNotEmpty) {
        grammar.add(GrammarPoint(
          type: 'Pronoun',
          title: word.isNotEmpty ? word : category,
          explanation: category.isNotEmpty && word.isNotEmpty
              ? '[$category] $explanation'
              : explanation,
          examples: exampleObjects,
        ));
      }
    }

    // Parse conjugations
    final conjList = (data['conjugations'] as List<dynamic>?) ?? [];
    final conjugations = conjList.map((c) {
      final map = c as Map<String, dynamic>;
      return ConjugationItem(
        form: map['form'] as String? ?? '',
        example: map['example'] as String? ?? '',
        translation: map['translation'] as String? ?? '',
        explanation: map['explanation'] as String? ?? '',
      );
    }).toList();

    // Parse word-level timestamps for karaoke sync
    final wordsList = (data['words'] as List<dynamic>?) ?? [];
    final words = wordsList.map((w) {
      final map = w as Map<String, dynamic>;
      return WordTimestamp(
        word: map['word'] as String? ?? '',
        start: (map['start'] as num?)?.toDouble() ?? 0.0,
        end: (map['end'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    // Parse Quiz List
    final quizList = (data['quiz'] as List<dynamic>?) ?? [];
    final quizItems = quizList.map((q) {
      final map = q as Map<String, dynamic>;
      return QuizItem(
        question: map['question'] as String? ?? '',
        hint: map['hint'] as String? ?? '',
        explanation: map['explanation'] as String? ?? '',
        correctAnswer: map['correct_answer'] as String? ?? '',
        wrongAnswers: (map['wrong_answers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
    }).toList();

    // Build the audio URL (TTS path from backend)
    // Backend now returns full URL, but handle relative paths as fallback
    final audioPath = data['audioUrl'] as String? ?? '';
    final audioUrl = audioPath.startsWith('http')
        ? audioPath
        : '$_backendBaseUrl$audioPath';

    return Memo(
      id: data['id'] as String? ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
      title: data['title'] as String? ?? 'AI Lesson',
      sourceUrl: originalUrl,
      sourcePlatform: data['sourcePlatform'] as String? ?? 'Unknown',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      date: DateTime.now(),
      language: language,
      summary: data['summary'] as String? ?? '',
      audioUrl: audioUrl,
      transcript: transcript,
      vocabulary: vocabulary,
      grammar: grammar,
      conjugations: conjugations,
      quiz: quizItems,
      words: words,
    );
  }
  /// 5. Format the raw transcription strictly adding punctuation/capitalization
  Future<String> formatTranscriptionWithAI(String rawString) async {
    final uri = Uri.parse('$_backendBaseUrl/api/copyedit');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': rawString}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['formatted_text'] as String? ?? rawString;
      }
      return rawString;
    } catch (_) {
      return rawString; // Silently fallback on timeout or error
    }
  }
}

/// Custom exception for AI service errors with user-friendly messages.
class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);

  @override
  String toString() => message;
}

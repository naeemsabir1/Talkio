import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:auraly_clone/core/models/memo_model.dart';
import 'package:auraly_clone/features/flashcards/screens/flashcards_screen.dart';

void main() {
  group('Flashcard Logic Tests', () {
    test('Progress calculation is correct', () {
      int currentIndex = 0;
      int totalCards = 10;
      
      double progress = (currentIndex + 1) / totalCards;
      expect(progress, equals(0.1));

      currentIndex = 4;
      progress = (currentIndex + 1) / totalCards;
      expect(progress, equals(0.5));

      currentIndex = 9;
      progress = (currentIndex + 1) / totalCards;
      expect(progress, equals(1.0));
    });

    test('Progress with zero cards', () {
      int currentIndex = 0;
      List<VocabularyItem> cards = [];
      
      double progress = cards.isEmpty ? 0.0 : (currentIndex + 1) / cards.length;
      expect(progress, equals(0.0));
    });

    test('Card index stays within bounds', () {
      int currentIndex = 0;
      int totalCards = 5;

      // Simulate swipes
      for (int i = 0; i < totalCards; i++) {
        expect(currentIndex, lessThan(totalCards));
        currentIndex = i + 1;
      }
    });

    test('Flip state toggles correctly', () {
      bool isFlipped = false;

      // First tap - flip to back
      isFlipped = !isFlipped;
      expect(isFlipped, isTrue);

      // Second tap - flip to front
      isFlipped = !isFlipped;
      expect(isFlipped, isFalse);

      // Third tap - flip to back again
      isFlipped = !isFlipped;
      expect(isFlipped, isTrue);
    });
  });

  group('Vocabulary Item Tests', () {
    test('VocabularyItem has all required fields', () {
      const vocab = VocabularyItem(
        word: 'Bonjour',
        pronunciation: 'bohn-ZHOOR',
        definition: 'Hello',
        example: 'Bonjour, comment allez-vous?',
      );

      expect(vocab.word, equals('Bonjour'));
      expect(vocab.pronunciation, equals('bohn-ZHOOR'));
      expect(vocab.definition, equals('Hello'));
      expect(vocab.example, equals('Bonjour, comment allez-vous?'));
    });

    test('VocabularyItem can have null example', () {
      const vocab = VocabularyItem(
        word: 'Bonjour',
        pronunciation: 'bohn-ZHOOR',
        definition: 'Hello',
      );

      expect(vocab.example, isNull);
    });
  });

  group('Flashcard Widget Tests', () {
    testWidgets('FlashcardsScreen displays title', (WidgetTester tester) async {
      final memo = Memo(
        id: 'test-id',
        title: 'Test Memo',
        sourceUrl: 'https://test.com',
        sourcePlatform: 'Instagram',
        thumbnailUrl: 'https://test.com/image.jpg',
        date: DateTime.now(),
        language: Language.english,
        summary: 'Test summary',
        audioUrl: 'https://test.com/audio.mp3',
        transcript: [],
        vocabulary: const [
          VocabularyItem(
            word: 'Hello',
            pronunciation: 'hel-oh',
            definition: 'A greeting',
          ),
        ],
        grammar: [],
        conjugations: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FlashcardsScreen(memo: memo),
        ),
      );

      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.text('Card 1 of 1'), findsOneWidget);
    });

    testWidgets('FlashcardsScreen displays empty state with no cards', (WidgetTester tester) async {
      final memo = Memo(
        id: 'test-id',
        title: 'Test Memo',
        sourceUrl: 'https://test.com',
        sourcePlatform: 'Instagram',
        thumbnailUrl: 'https://test.com/image.jpg',
        date: DateTime.now(),
        language: Language.english,
        summary: 'Test summary',
        audioUrl: 'https://test.com/audio.mp3',
        transcript: [],
        vocabulary: [], // Empty vocabulary list
        grammar: [],
        conjugations: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FlashcardsScreen(memo: memo),
        ),
      );

      expect(find.text('No vocabulary cards available'), findsOneWidget);
    });

    testWidgets('FlashcardsScreen displays instructions', (WidgetTester tester) async {
      final memo = Memo(
        id: 'test-id',
        title: 'Test Memo',
        sourceUrl: 'https://test.com',
        sourcePlatform: 'Instagram',
        thumbnailUrl: 'https://test.com/image.jpg',
        date: DateTime.now(),
        language: Language.english,
        summary: 'Test summary',
        audioUrl: 'https://test.com/audio.mp3',
        transcript: [],
        vocabulary: const [
          VocabularyItem(
            word: 'Hello',
            pronunciation: 'hel-oh',
            definition: 'A greeting',
          ),
        ],
        grammar: [],
        conjugations: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FlashcardsScreen(memo: memo),
        ),
      );

      expect(find.text('Tap to flip • Swipe to continue'), findsOneWidget);
    });
  });
}

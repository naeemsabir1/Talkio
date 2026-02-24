import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auraly_clone/core/services/mock_content_service.dart';
import 'package:auraly_clone/core/providers/memo_provider.dart';
import 'package:auraly_clone/core/models/memo_model.dart';

void main() {
  group('Share Extension Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Memo is created from shared URL', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const testUrl = 'https://instagram.com/p/test123';

      // Act
      final memo = await service.getMemoFromUrl(testUrl, 'English');

      // Assert
      expect(memo, isNotNull);
      expect(memo.title, isNotEmpty);
      expect(memo.sourceUrl, equals(testUrl));
    });

    test('Platform is detected from Instagram URL', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const instagramUrl = 'https://instagram.com/p/test123';

      // Act
      final memo = await service.getMemoFromUrl(instagramUrl, 'English');

      // Assert
      expect(memo.sourcePlatform, equals('Instagram'));
    });

    test('Platform is detected from YouTube URL', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const youtubeUrl = 'https://youtube.com/watch?v=test123';

      // Act
      final memo = await service.getMemoFromUrl(youtubeUrl, 'English');

      // Assert
      expect(memo.sourcePlatform, equals('YouTube'));
    });

    test('Platform is detected from TikTok URL', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const tiktokUrl = 'https://tiktok.com/@user/video/test123';

      // Act
      final memo = await service.getMemoFromUrl(tiktokUrl, 'English');

      // Assert
      expect(memo.sourcePlatform, equals('TikTok'));
    });

    test('Each shared memo has unique ID', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const testUrl = 'https://instagram.com/p/test123';

      // Act
      final memo1 = await service.getMemoFromUrl(testUrl, 'English');
      await Future.delayed(const Duration(milliseconds: 10)); // Ensure different timestamp
      final memo2 = await service.getMemoFromUrl(testUrl, 'English');

      // Assert
      expect(memo1.id, isNot(equals(memo2.id)));
    });

    test('Memo is added to memosProvider', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const testUrl = 'https://instagram.com/p/test123';
      final initialMemos = container.read(memosProvider);
      final initialCount = initialMemos.length;

      // Act
      final memo = await service.getMemoFromUrl(testUrl, 'English');
      container.read(memosProvider.notifier).state = [
        memo,
        ...initialMemos,
      ];

      final updatedMemos = container.read(memosProvider);

      // Assert
      expect(updatedMemos.length, equals(initialCount + 1));
      expect(updatedMemos.first.id, equals(memo.id));
    });

    test('Mock memo contains all required data', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const testUrl = 'https://instagram.com/p/test123';

      // Act
      final memo = await service.getMemoFromUrl(testUrl, 'English');

      // Assert
      expect(memo.summary, isNotEmpty);
      expect(memo.transcript, isNotEmpty);
      expect(memo.vocabulary, isNotEmpty);
      expect(memo.grammar, isNotEmpty);
      expect(memo.title, equals('The "Aura" Conversation'));
    });

    test('Processing delay is approximately 3 seconds', () async {
      // Arrange
      final service = container.read(mockContentServiceProvider);
      const testUrl = 'https://instagram.com/p/test123';
      final stopwatch = Stopwatch()..start();

      // Act
      await service.getMemoFromUrl(testUrl, 'English');
      stopwatch.stop();

      // Assert - Should be around 3000ms (allowing 500ms variance)
      expect(stopwatch.elapsedMilliseconds, greaterThan(2500));
      expect(stopwatch.elapsedMilliseconds, lessThan(3500));
    });
  });
}

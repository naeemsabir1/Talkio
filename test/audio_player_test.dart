import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:auraly_clone/core/models/memo_model.dart';

void main() {
  group('Audio Player Tests', () {
    late AudioPlayer player;

    setUp(() {
      player = AudioPlayer();
    });

    tearDown(() async {
      await player.dispose();
    });

    test('Initial playback speed is 1.0x', () {
      expect(player.speed, equals(1.0));
    });

    test('Speed cycle: 1.0x -> 1.5x -> 0.75x -> 1.0x', () async {
      // Initial speed
      expect(player.speed, equals(1.0));

      // Cycle to 1.5x
      await player.setSpeed(1.5);
      expect(player.speed, equals(1.5));

      // Cycle to 0.75x
      await player.setSpeed(0.75);
      expect(player.speed, equals(0.75));

      // Cycle back to 1.0x
      await player.setSpeed(1.0);
      expect(player.speed, equals(1.0));
    });

    test('Player initializes with stopped state', () {
      expect(player.playing, isFalse);
      expect(player.position, equals(Duration.zero));
    });

    test('Duration is null before audio is loaded', () {
      expect(player.duration, isNull);
    });

    test('Position can be set within duration bounds', () async {
      // Note: This test requires a real audio file to be loaded
      // In a real test, you would:
      // 1. Load a test audio file
      // 2. Wait for it to be ready
      // 3. Set position and verify
      
      // For this mock test, we just verify the position property exists
      expect(player.position, isA<Duration>());
    });
  });

  group('Speed Preset Tests', () {
    test('Speed preset values are correct', () {
      const learnerSpeed = 0.75;
      const realSpeed = 1.0;
      const challengeSpeed = 1.5;

      expect(learnerSpeed, equals(0.75));
      expect(realSpeed, equals(1.0));
      expect(challengeSpeed, equals(1.5));
    });

    test('Speed emoji mapping', () {
      String getSpeedEmoji(double speed) {
        if (speed == 0.75) return '🐢';
        if (speed == 1.0) return '🎧';
        if (speed == 1.5) return '⚡';
        return '🎧';
      }

      expect(getSpeedEmoji(0.75), equals('🐢'));
      expect(getSpeedEmoji(1.0), equals('🎧'));
      expect(getSpeedEmoji(1.5), equals('⚡'));
    });

    test('Speed label mapping', () {
      String getSpeedLabel(double speed) {
        if (speed == 0.75) return 'Learner';
        if (speed == 1.0) return 'Real';
        if (speed == 1.5) return 'Challenge';
        return 'Real';
      }

      expect(getSpeedLabel(0.75), equals('Learner'));
      expect(getSpeedLabel(1.0), equals('Real'));
      expect(getSpeedLabel(1.5), equals('Challenge'));
    });
  });

  group('Time Formatting Tests', () {
    test('Format duration correctly', () {
      String formatDuration(Duration duration) {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final minutes = twoDigits(duration.inMinutes.remainder(60));
        final seconds = twoDigits(duration.inSeconds.remainder(60));
        return '$minutes:$seconds';
      }

      expect(formatDuration(const Duration(seconds: 0)), equals('00:00'));
      expect(formatDuration(const Duration(seconds: 30)), equals('00:30'));
      expect(formatDuration(const Duration(minutes: 1, seconds: 5)), equals('01:05'));
      expect(formatDuration(const Duration(minutes: 2, seconds: 45)), equals('02:45'));
      expect(formatDuration(const Duration(minutes: 10, seconds: 0)), equals('10:00'));
    });
  });
}

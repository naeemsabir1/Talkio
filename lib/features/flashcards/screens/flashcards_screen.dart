import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../../core/models/memo_model.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class FlashcardsScreen extends StatefulWidget {
  final Memo memo;

  const FlashcardsScreen({super.key, required this.memo});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final CardSwiperController _controller = CardSwiperController();
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final cards = widget.memo.vocabulary;
    final progress = cards.isEmpty ? 0.0 : (_currentIndex + 1) / cards.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Card ${math.min(_currentIndex + 1, cards.length)} of ${cards.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cards.isEmpty
                  ? const Center(child: Text('No vocabulary cards available'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CardSwiper(
                        controller: _controller,
                        cardsCount: cards.length,
                        onSwipe: (previousIndex, currentIndex, direction) {
                          setState(() {
                            _currentIndex = currentIndex ?? previousIndex;
                            _isFlipped = false;
                          });
                          return true;
                        },
                        cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                          return _buildFlashcard(cards[index]);
                        },
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Tap to flip • Swipe to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcard(VocabularyItem vocab) {
    return GestureDetector(
      onTap: () => setState(() => _isFlipped = !_isFlipped),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = Tween(begin: math.pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final angle = rotate.value;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);
              return Transform(
                transform: transform,
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: _isFlipped
            ? _buildCardBack(vocab)
            : _buildCardFront(vocab),
      ),
    );
  }

  Widget _buildCardFront(VocabularyItem vocab) {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                vocab.word,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                vocab.pronunciation,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(VocabularyItem vocab) {
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Definition',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                vocab.meaning,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (vocab.example != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Example',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vocab.example!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

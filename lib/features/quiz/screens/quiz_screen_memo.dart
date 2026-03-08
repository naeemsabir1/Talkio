import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/memo_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';

class QuizScreenMemo extends StatefulWidget {
  final Memo memo;

  const QuizScreenMemo({super.key, required this.memo});

  @override
  State<QuizScreenMemo> createState() => _QuizScreenMemoState();
}

class _QuizScreenMemoState extends State<QuizScreenMemo> {
  final ConfettiController _confettiController = ConfettiController();
  int _currentQuestion = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<QuizItem> _getQuestions() {
    return widget.memo.quiz;
  }

  void _checkAnswer(String answer, String correct) {
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correct) {
        _score++;
        _confettiController.play();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (_currentQuestion < _getQuestions().length - 1) {
            _confettiController.stop(); // Stop confetti
            _currentQuestion++;
            _selectedAnswer = null;
            _answered = false;
          } else {
            _showResults();
          }
        });
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('home.action_quiz'.tr() + ' Complete!'),
        content: Text('Your score: $_score / ${_getQuestions().length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestion = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions();
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('home.action_quiz'.tr())),
        body: Center(child: Text('No quiz questions available')),
      );
    }

    final question = questions[_currentQuestion];
    // Keep internal local memory per question shuffle order
    final allAnswers = [question.correctAnswer, ...question.wrongAnswers]..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: Text('home.action_quiz'.tr()),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: $_score/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestion + 1) / questions.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Question ${_currentQuestion + 1} of ${questions.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                    GlassCard(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      borderColor: AppTheme.primary.withOpacity(0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (question.hint.isNotEmpty && !_answered)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.tips_and_updates, color: Colors.orange, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      question.hint,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.orange.shade800,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...allAnswers.map((answer) {
                      final isSelected = _selectedAnswer == answer;
                      final isCorrect = answer == question.correctAnswer;
                    Color? bgColor;
                    Color? borderColor;

                    if (_answered && isSelected) {
                      bgColor = isCorrect
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2);
                      borderColor = isCorrect ? Colors.green : Colors.red;
                    } else if (_answered && isCorrect) {
                      bgColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: _answered ? null : () => _checkAnswer(answer, question.correctAnswer),
                        backgroundColor: bgColor ?? Colors.white.withOpacity(0.7),
                        borderColor: borderColor ?? Colors.grey.shade300,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                answer,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle, color: Colors.green),
                            if (_answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

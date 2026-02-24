import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class ProcessingOverlay extends StatefulWidget {
  final String? url;

  const ProcessingOverlay({super.key, this.url});

  @override
  State<ProcessingOverlay> createState() => _ProcessingOverlayState();
}

class _ProcessingOverlayState extends State<ProcessingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentTextIndex = 0;
  late List<String> _statusTexts;

  @override
  void initState() {
    super.initState();
    _statusTexts = [
      '🔗 Connecting to source...',
      '🧠 Analyzing content...',
      '📝 Extracting transcript...',
      '🎯 Identifying key vocabulary...',
      '✨ Creating your memo...',
    ];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Cycle through status texts
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _statusTexts.length;
        });
        return true;
      }
      return false;
    });

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.white.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulsing Ripple Circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: RipplePainter(
                            animationValue: _controller.value,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated Status Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _statusTexts[_currentTextIndex],
                      key: ValueKey(_currentTextIndex),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2962FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animationValue;

  RipplePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw 3 concentric ripples
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (animationValue + (i * 0.33)) % 1.0;
      final radius = rippleProgress * (size.width / 2);
      final opacity = (1 - rippleProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color(0xFF2962FF).withOpacity(opacity * 0.6),
            Color(0xFF9C27B0).withOpacity(opacity * 0.3),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw center gradient circle
    final centerPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF2962FF),
          Color(0xFF9C27B0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 40));

    canvas.drawCircle(center, 40, centerPaint);

    // Draw pulsing white overlay
    final pulseOpacity = (math.sin(animationValue * 2 * math.pi) * 0.3 + 0.3).clamp(0.0, 1.0);
    final pulsePaint = Paint()
      ..color = Colors.white.withOpacity(pulseOpacity);
    canvas.drawCircle(center, 40, pulsePaint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

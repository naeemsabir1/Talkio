import 'package:flutter/material.dart';
import 'section_card.dart';
import '../../../core/models/memo_model.dart';

class TranslationCard extends StatelessWidget {
  final List<TranscriptSegment> segments;
  final bool isVisible;

  const TranslationCard({
    super.key,
    required this.segments,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || segments.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Translation',
      icon: Icons.translate_rounded,
      accentColor: const Color(0xFF8B5CF6), // Purple
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: segments.map((segment) {
          // Skip if translation is same as original (Native Mode fallback)
          if (segment.translation == segment.original) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp (optional)
                Text(
                  _formatTimestamp(segment.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                    fontFamily: 'Monospace',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    segment.translation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.5,
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatTimestamp(double seconds) {
    final int min = seconds ~/ 60;
    final int sec = (seconds % 60).toInt();
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

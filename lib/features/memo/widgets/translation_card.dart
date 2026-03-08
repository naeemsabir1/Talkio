import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
      title: 'memo_sections.translation'.tr(),
      icon: Icons.translate_rounded,
      accentColor: const Color(0xFF8B5CF6), // Purple
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.6, // Enhanced line height for readability
                fontFamily: 'Inter',
                fontStyle: FontStyle.italic,
              ),
              children: segments.expand((segment) {
                if (segment.translation == segment.original) return <TextSpan>[];
                return [
                  TextSpan(text: segment.translation),
                  const TextSpan(text: ' '),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(double seconds) {
    final int min = seconds ~/ 60;
    final int sec = (seconds % 60).toInt();
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

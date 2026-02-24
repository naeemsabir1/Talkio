import 'package:flutter/material.dart';
import 'section_card.dart';

class SummaryCard extends StatelessWidget {
  final String summary;

  const SummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Summary', // Localize later if needed
      icon: Icons.article_rounded,
      accentColor: const Color(0xFFF59E0B), // Amber for summary
      child: Text(
        summary,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          height: 1.6,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'section_card.dart';
import '../../../core/models/memo_model.dart';

class PronounsCard extends StatelessWidget {
  final List<GrammarPoint> grammarPoints;

  const PronounsCard({
    super.key,
    required this.grammarPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Filter FOR Pronouns
    final pronouns = grammarPoints.where((g) => g.type.toLowerCase() == 'pronoun').toList();

    if (pronouns.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Pronouns',
      icon: Icons.person_rounded,
      accentColor: const Color(0xFFEC4899), // Pink
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pronouns.map((p) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (p.explanation.length < 50) // Only show short explanations in chips
                  Text(
                    p.explanation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'section_card.dart';
import '../../../core/models/memo_model.dart';
import '../../../core/widgets/dark_grammar_card.dart';

class GrammarCard extends StatelessWidget {
  final List<GrammarPoint> grammarPoints;

  const GrammarCard({
    super.key,
    required this.grammarPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out Pronouns as they have their own card
    final filteredPoints = grammarPoints.where((g) => g.type.toLowerCase() != 'pronoun').toList();

    if (filteredPoints.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Grammar',
      icon: Icons.lightbulb_rounded,
      accentColor: const Color(0xFFEAB308), // Yellow
      child: Column(
        children: filteredPoints.map((point) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DarkGrammarCard(grammarPoint: point),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
    // Filter FOR Pronouns (case-insensitive match)
    final pronouns = grammarPoints
        .where((g) => g.type.toLowerCase() == 'pronoun')
        .toList();

    if (pronouns.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'memo_sections.pronouns'.tr(),
      icon: Icons.person_rounded,
      accentColor: const Color(0xFFEC4899), // Pink
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pronouns.map((p) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFEC4899).withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pronoun word (title)
                Text(
                  p.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
                if (p.explanation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    p.explanation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
                if (p.examples.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...p.examples.map((ex) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC4899).withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.sentence,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12.5,
                                  fontFamily: 'Inter',
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                              if (ex.translation.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    ex.translation,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 11.5,
                                      fontFamily: 'Inter',
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'section_card.dart';
import '../../../core/models/memo_model.dart';

class ConjugationCard extends StatelessWidget {
  final List<ConjugationItem> conjugations;

  const ConjugationCard({
    super.key,
    required this.conjugations,
  });

  @override
  Widget build(BuildContext context) {
    if (conjugations.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Conjugation',
      icon: Icons.sync_rounded,
      accentColor: const Color(0xFF3B82F6), // Blue
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Tense/Form'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      'Example'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            
            // Items
            ...conjugations.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == conjugations.length - 1;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: isLast ? null : const Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.form,
                        style: const TextStyle(
                          color: Color(0xFF60A5FA),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        item.example,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

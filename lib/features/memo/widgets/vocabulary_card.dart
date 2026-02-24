import 'package:flutter/material.dart';
import 'section_card.dart';
import '../../../core/models/memo_model.dart';

class VocabularyCard extends StatelessWidget {
  final List<VocabularyItem> vocabulary;

  const VocabularyCard({
    super.key,
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context) {
    if (vocabulary.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Vocabulary',
      icon: Icons.menu_book_rounded,
      accentColor: const Color(0xFF10B981), // Emerald for vocab
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 450), // Increased height for the massive grid layout
            child: Scrollbar(
              thumbVisibility: true,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.white.withOpacity(0.05),
                      ),
                      child: DataTable(
                        columnSpacing: 32,
                        headingRowHeight: 60,
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: double.infinity,
                        headingTextStyle: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                        dataTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        columns: const [
                          DataColumn(label: Text('Word')),
                          DataColumn(label: Text('Pronunciation')),
                          DataColumn(label: Text('Significance')),
                          DataColumn(label: Text('Explanation')),
                        ],
                        rows: vocabulary.map((item) {
                          return DataRow(
                            cells: [
                              // Word
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    item.word,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              // Pronunciation
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    item.pronunciation,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              // Significance (Example)
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: SizedBox(
                                    width: 250, // Constrain width for horizontal scrolling relevance
                                    child: Text(
                                      item.example ?? '-',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Explanation (Definition)
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: SizedBox(
                                    width: 300, // Constrain width to encourage horizontal scrolling if long
                                    child: Text(
                                      item.definition,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

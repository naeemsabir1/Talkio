import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
      title: 'memo_sections.conjugation'.tr(),
      icon: Icons.sync_rounded,
      accentColor: const Color(0xFF3B82F6), // Blue
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
            constraints: const BoxConstraints(maxHeight: 450), 
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
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                        dataTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        columns: [
                          DataColumn(label: Text('data_table.form'.tr())),
                          DataColumn(label: Text('data_table.example'.tr())),
                          DataColumn(label: Text('data_table.translation'.tr())),
                          DataColumn(label: Text('data_table.explanation'.tr())),
                        ],
                        rows: conjugations.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    item.form,
                                    style: const TextStyle(
                                      color: Color(0xFF60A5FA),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: SizedBox(
                                    width: 250,
                                    child: Text(
                                      item.example,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: SizedBox(
                                    width: 250,
                                    child: Text(
                                      item.translation,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: SizedBox(
                                    width: 300,
                                    child: Text(
                                      item.explanation,
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

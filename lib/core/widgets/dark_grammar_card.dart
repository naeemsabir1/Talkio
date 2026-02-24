import 'package:flutter/material.dart';
import '../models/memo_model.dart';

/// Dark-themed grammar card widget that displays grammar points
/// MUST be dark even though the app is in light mode (matches PDF design)
class DarkGrammarCard extends StatelessWidget {
  final GrammarPoint grammarPoint;
  
  const DarkGrammarCard({
    super.key,
    required this.grammarPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              grammarPoint.type.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF94A3B8), // Slate gray
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            grammarPoint.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Explanation
          Text(
            grammarPoint.explanation,
            style: const TextStyle(
              color: Color(0xFF94A3B8), // Slate gray
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Examples title
          const Text(
            'Examples:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Example bullets
          ...grammarPoint.examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 6,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    example,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

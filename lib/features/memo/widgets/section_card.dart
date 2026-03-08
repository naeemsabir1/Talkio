import 'package:flutter/material.dart';
import 'dart:ui';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? accentColor;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        // High-performance glassmorphism illusion using gradient instead of BackdropFilter
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withOpacity(0.7),
            const Color(0xFF0F172A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: [
          // Outer glow with accent color
          BoxShadow(
            color: accent.withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          // Subtle dark shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accent.withOpacity(0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}

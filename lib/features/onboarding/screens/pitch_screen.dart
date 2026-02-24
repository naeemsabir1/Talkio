import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../assets/generated_art.dart';
import '../../../core/theme/app_theme.dart';

import 'dart:ui';
class PitchScreen extends StatefulWidget {
  const PitchScreen({super.key});

  @override
  State<PitchScreen> createState() => _PitchScreenState();
}

class _PitchScreenState extends State<PitchScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      context.push('/tutorial');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.3),
                    const Color(0xFF7C3AED).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
             bottom: -100,
             right: -100,
             child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.2),
                    const Color(0xFFEC4899).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildChartPage(),
                  _buildLevelPage(),
                  _buildTextPage(
                    "Learning a language\nfeels hard?",
                    "New words disappear fast,\nand studying feels boring...",
                    'assets/images/pitch_thinking.png',
                  ),
                  _buildTextPage(
                    "Good News!",
                    "Now you can learn naturally\nfrom what you love!",
                    'assets/images/pitch_waving.png',
                    isLast: true,
                  ),
                ],
              ),
            ),
            
              // Only show button on non-selection pages (Chart, Problem, Solution)
              if (_currentPage != 1) 
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        _currentPage == 3 ? "Show me how it works!" : "Continue",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ],
      ),    );
  }

  Widget _buildChartPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Less effort,\nFaster progress!", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Expanded(child: Image.asset('assets/images/pitch_chart.png', fit: BoxFit.contain)),
        ],
      ),
    );
  }

  Widget _buildLevelPage() {
    final levels = ["Beginner A1", "Intermediate B1", "Upper Intermediate B2", "Advanced C1"];
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text("What is your current\nEnglish Level?", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.separated(
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: _nextPage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      levels[index],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPage(String title, String subtitle, String assetName, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3, 
            child: assetName.startsWith('assets') 
              ? Image.asset(assetName, fit: BoxFit.contain)
              : SvgPicture.string(assetName)
          ),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60, height: 1.5), textAlign: TextAlign.center),
          const Spacer(),
        ],
      ),
    );
  }
}

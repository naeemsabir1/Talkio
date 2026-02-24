import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../assets/generated_art.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';
import 'dart:ui';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  bool _isNameValid = false;

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && !_isNameValid) return;
    
    // Dismiss keyboard when navigating away
    FocusManager.instance.primaryFocus?.unfocus();

    if (_currentPage == 0) {
      // Save name
      ref.read(storageServiceProvider).setUserName(_nameController.text.trim());
    }

    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      context.push('/quiz');
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
            right: -100,
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
             left: -100,
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
                      _buildNameInputPage(),
                      const _OnboardingPage(
                        assetName: 'assets/images/onboarding_1.png',
                        title: "Learn a new language.\nBare minimum required.",
                        buttonText: "Scroll. Watch. Learn.",
                        isFirstPage: true,
                      ),
                      const _OnboardingPage(
                        assetName: 'assets/images/onboarding_2.png',
                        title: "From 'I don't get it'\nto 'I get this!'",
                        subtitle: "Hate studying? Just watch\nand learn instantly.",
                        buttonText: "Continue",
                      ),
                      const _OnboardingPage(
                        assetName: 'assets/images/onboarding_3.png', 
                        title: "Ready when you are,\nlet's start!",
                        buttonText: "Get Started",
                        isLastPage: true,
                      ),
                    ],
                  ),
                ),
                
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF7C3AED) : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildBottomButton(),
    );
  }

  Widget _buildNameInputPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.waving_hand_rounded, color: Color(0xFF7C3AED), size: 40),
          ),
          const SizedBox(height: 32),
          Text(
            "What should we\ncall you?",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 16),
          Text(
            "Your journey to language mastery begins here.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Theme(
                  data: ThemeData.dark().copyWith(
                    primaryColor: Colors.white,
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Colors.white,
                      selectionColor: Colors.white24,
                      selectionHandleColor: Colors.white,
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      decorationColor: Colors.white, 
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: "Enter your name",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4), 
                        fontSize: 24, 
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _isNameValid = val.trim().isNotEmpty;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    String btnText = "Next";
    if (_currentPage == 0) btnText = "Continue";
    if (_currentPage == 1) btnText = "Scroll. Watch. Learn.";
    if (_currentPage == 2) btnText = "Next";
    if (_currentPage == 3) btnText = "Get Started";

    bool isEnabled = _currentPage != 0 || _isNameValid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: isEnabled ? const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isEnabled ? null : Colors.white12,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: ElevatedButton(
          onPressed: isEnabled ? _nextPage : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            btnText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String assetName;
  final String title;
  final String? subtitle;
  final String buttonText;
  final bool isFirstPage;
  final bool isLastPage;

  const _OnboardingPage({
    required this.assetName,
    required this.title,
    this.subtitle,
    required this.buttonText,
    this.isFirstPage = false,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic
          Expanded(
            flex: 3,
            child: assetName.endsWith('.svg') 
              ? SvgPicture.asset(
                  assetName,
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) => const Center(
                     child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  ),
                )
              : Image.asset(
                  assetName,
                  fit: BoxFit.contain,
                ),
          ),
          
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

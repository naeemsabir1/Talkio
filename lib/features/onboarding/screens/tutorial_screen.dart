import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../assets/generated_art.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _finishOnboarding() {
    ref.read(storageServiceProvider).setOnboardingComplete();
    context.go('/home'); // Use go to clear stack
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildStepPage("Step 1: Share", "Open a video on YouTube\nor TikTok and tap Share", 'assets/images/tutorial_1.svg'),
                      _buildStepPage("Step 2: Tap More", "Find the 'More' button\nin the share sheet", 'assets/images/tutorial_2.svg'),
                      _buildStepPage("Step 3: Choose Talkio", "Select Talkio from the list\nto create your memo", 'assets/images/tutorial_3.svg'),
                    ],
                  ),
                ),
                // Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                     return AnimatedContainer(
                       duration: const Duration(milliseconds: 300),
                       margin: const EdgeInsets.symmetric(horizontal: 4),
                       height: 8,
                       width: _currentPage == index ? 24 : 8,
                       decoration: BoxDecoration(
                         color: _currentPage == index ? AppTheme.primary : AppTheme.surfaceHighlight,
                         borderRadius: BorderRadius.circular(4),
                       ),
                     );
                  }),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(_currentPage == 2 ? "Get Started" : "Next"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPage(String title, String subtitle, String assetName) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
            width: 250, height: 250, // Increased size for illustration
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
             child: assetName.endsWith('.svg') 
               ? SvgPicture.asset(
                   assetName,
                   fit: BoxFit.contain,
                   placeholderBuilder: (context) => Center(
                     child: CircularProgressIndicator(color: AppTheme.primary),
                   ),
                 )
               : Image.asset(
                   assetName,
                   fit: BoxFit.contain,
                 ),
          ),
          const SizedBox(height: 40),
          Text(title, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 60),
        ],
      ),
      ),
    );
  }
}

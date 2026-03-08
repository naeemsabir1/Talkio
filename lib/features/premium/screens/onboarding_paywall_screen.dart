import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/revenuecat_service.dart';
import '../../../core/services/storage_service.dart';

class OnboardingPaywallScreen extends ConsumerStatefulWidget {
  const OnboardingPaywallScreen({super.key});

  @override
  ConsumerState<OnboardingPaywallScreen> createState() => _OnboardingPaywallScreenState();
}

class _OnboardingPaywallScreenState extends ConsumerState<OnboardingPaywallScreen> {
  bool _isLoadingProducts = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _yearlyPackage;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    final revenueCat = ref.read(revenueCatServiceProvider);
    
    // Ensure initialized
    if (!revenueCat.isInitialized) {
      await revenueCat.initialize();
    }
    
    final offerings = await revenueCat.getOfferings();
    
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _isLoadingProducts = false;
        
        // Find the yearly package specifically for the 7-day trial offering
        if (_offerings != null && _offerings!.current != null) {
          final current = _offerings!.current!;
          _yearlyPackage = current.annual;
          
          // Fallback if no annual named "annual" exists, grab the first available package
          if (_yearlyPackage == null && current.availablePackages.isNotEmpty) {
            _yearlyPackage = current.availablePackages.first;
          }
        }
      });
    }
  }

  void _finishOnboardingAndGoHome() {
    ref.read(storageServiceProvider).setOnboardingComplete();
    context.go('/home');
  }

  Future<void> _handleClaimTrial() async {
    if (_yearlyPackage == null) return;
    
    setState(() {
      _isPurchasing = true;
    });

    final revenueCat = ref.read(revenueCatServiceProvider);
    final success = await revenueCat.purchasePackage(_yearlyPackage!);

    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      if (success) {
        _finishOnboardingAndGoHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate
      body: Stack(
        children: [
          // Background Gradient / Decor
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.3), // Violet
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.2), // Pink
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Floating Gift Icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B), // Slate 800
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: -5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.6),
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.white,
                                size: 64,
                              ),
                              Positioned(
                                top: 18,
                                right: 18,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B), // Amber
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Headline
                      Text(
                        'Get your 7 days\nFree Trial',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Experience the massive speed boost in your fluency with Talkio Pro. Unlock full access to AI tools, translations, and unlimited vocabulary tracking.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Premium Glass Card for Yearly Offer
                      _buildOfferSummary(),

                      const SizedBox(height: 40),

                      // Primary CTA: Claim Free Trial
                      _buildClaimButton(),

                      const SizedBox(height: 20),

                      // Secondary CTA: Maybe Later
                      TextButton(
                        onPressed: _isPurchasing ? null : _finishOnboardingAndGoHome,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white60,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Maybe later',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isPurchasing)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfferSummary() {
    if (_isLoadingProducts) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );
    }

    if (_yearlyPackage == null) {
      return const SizedBox.shrink(); // Hide if failed to load
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15), // Emerald
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Talkio Pro Annual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '7 days completely free, then ${_yearlyPackage!.storeProduct.priceString}/year. Cancel anytime.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton() {
    return GestureDetector(
      onTap: _isLoadingProducts || _isPurchasing ? null : _handleClaimTrial,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoadingProducts
                ? [Colors.white24, Colors.white12]
                : [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isLoadingProducts
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isLoadingProducts
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  'Claim free trial',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

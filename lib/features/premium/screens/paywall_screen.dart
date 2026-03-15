import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/revenuecat_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoadingProducts = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _selectedPackage;

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
        
        // Default to yearly if available (which carries the 7-day trial)
        if (_offerings != null && _offerings!.current != null) {
          final current = _offerings!.current!;
          if (current.annual != null) {
            _selectedPackage = current.annual;
          } else if (current.monthly != null) {
            _selectedPackage = current.monthly;
          } else if (current.availablePackages.isNotEmpty) {
            _selectedPackage = current.availablePackages.first;
          }
        }
      });
    }
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;
    
    setState(() {
      _isPurchasing = true;
    });

    final revenueCat = ref.read(revenueCatServiceProvider);
    final success = await revenueCat.purchasePackage(_selectedPackage!);

    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      if (success) {
        Navigator.of(context).pop(true); // Return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('paywall.error_purchase'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isPurchasing = true;
    });

    final revenueCat = ref.read(revenueCatServiceProvider);
    final success = await revenueCat.restorePurchases();

    if (mounted) {
      setState(() {
        _isPurchasing = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('paywall.error_restore'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101E),
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
                    AppTheme.primary.withOpacity(0.3),
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
                    AppTheme.secondary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildVisualMascot(),
                          const SizedBox(height: 24),
                          _buildHeadline(),
                          const SizedBox(height: 32),
                          _buildFeatureList(),
                          const SizedBox(height: 40),
                          _buildPricingSection(),
                          const SizedBox(height: 40), // Space for Sticky bottom CTA
                        ],
                      ),
                    ),
                  ),
                ),
                _buildStickyFooter(),
              ],
            ),
          ),

          // Loading Overlay
          if (_isPurchasing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            onPressed: _handleRestore,
            child: Text(
              'paywall.restore_purchases'.tr(),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualMascot() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: AppTheme.primary,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Text(
      'paywall.headline'.tr(),
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.lock_open_rounded,
          title: 'paywall.features.full_access'.tr(),
          description: 'paywall.features.full_access_desc'.tr(),
          iconColor: const Color(0xFF10B981), // Emerald
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.play_circle_fill_rounded,
          title: 'paywall.features.smart_video'.tr(),
          description: 'paywall.features.smart_video_desc'.tr(),
          iconColor: const Color(0xFF3B82F6), // Blue
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.trending_up_rounded,
          title: 'paywall.features.personalized'.tr(),
          description: 'paywall.features.personalized_desc'.tr(),
          iconColor: const Color(0xFFF59E0B), // Amber
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.speaker_notes_rounded,
          title: 'paywall.features.unlimited_vocab'.tr(),
          description: 'paywall.features.unlimited_vocab_desc'.tr(),
          iconColor: const Color(0xFF8B5CF6), // Violet
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    if (_isLoadingProducts) {
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(height: 16),
            Text('paywall.loading'.tr(), style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_offerings == null || _offerings!.current == null || _offerings!.current!.availablePackages.isEmpty) {
      return Center(
        child: Text(
          'paywall.error_loading_products'.tr(),
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    final currentOfferings = _offerings!.current!;
    final monthlyPackage = currentOfferings.monthly;
    final annualPackage = currentOfferings.annual;

    if (monthlyPackage == null && annualPackage == null) {
      // Fallback
      return Column(
        children: currentOfferings.availablePackages.map((pkg) => _buildPackageCard(pkg)).toList(),
      );
    }

    return Row(
      children: [
        if (monthlyPackage != null)
          Expanded(child: _buildPackageCard(monthlyPackage, isYearly: false)),
        if (monthlyPackage != null && annualPackage != null)
          const SizedBox(width: 16),
        if (annualPackage != null)
          Expanded(child: _buildPackageCard(annualPackage, isYearly: true)),
      ],
    );
  }

  Widget _buildPackageCard(Package package, {bool isYearly = false}) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    final title = isYearly ? 'paywall.yearly'.tr() : 'paywall.monthly'.tr();
    final priceStr = package.storeProduct.priceString;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  priceStr,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isYearly && isSelected) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cancel anytime',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  )
                ]
              ],
            ),
            if (isYearly)
              Positioned(
                top: -36,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'paywall.7_days_free'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter() {
    final isYearly = _selectedPackage?.packageType == PackageType.annual;
    final buttonText = isYearly ? 'paywall.cta_trial'.tr() : 'paywall.cta_continue'.tr();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101E),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B101E).withOpacity(0.9),
            blurRadius: 40,
            spreadRadius: 20,
            offset: const Offset(0, -20),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isLoadingProducts ? null : _handlePurchase,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoadingProducts
                      ? [Colors.grey.shade600, Colors.grey.shade800]
                      : [AppTheme.primary, const Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isLoadingProducts
                    ? []
                    : [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'paywall.cancel_anytime'.tr(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://naeemsabir1.github.io/Talkio/terms.html')),
                child: Text(
                  'paywall.terms_of_service'.tr(),
                  style: const TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse('https://naeemsabir1.github.io/Talkio/privacy.html')),
                child: Text(
                  'paywall.privacy_policy'.tr(),
                  style: const TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

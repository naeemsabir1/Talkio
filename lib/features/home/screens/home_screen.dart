import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../assets/generated_art.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/memo_provider.dart';
import '../../../core/models/memo_model.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/processing_overlay.dart';
import '../../../core/widgets/language_switcher.dart';
import '../widgets/language_picker_sheet.dart';
import '../../../features/home/screens/share_processing_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../memo/screens/memo_detail_screen.dart';
import '../../flashcards/screens/flashcards_screen.dart';
import '../../quiz/screens/quiz_screen_memo.dart';
import '../../profile/screens/account_settings_screen.dart';
import '../../profile/screens/help_center_screen.dart';
import '../../../core/services/revenuecat_service.dart';
import '../../premium/screens/paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: _currentIndex == 0 ? const HomeView() : const ProfileView(),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_filled, 'home.nav_home'.tr()),
            _buildNavItem(1, Icons.person_rounded, 'home.nav_profile'.tr()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : Colors.grey.shade400,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  void _showAddMemoModal(BuildContext context, WidgetRef ref) async {
    final revenueCat = ref.read(revenueCatServiceProvider);
    if (!revenueCat.isPremiumUser()) {
      final purchased = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(),
          fullscreenDialog: true,
        ),
      );
      if (purchased != true) return;
    }

    final TextEditingController urlController = TextEditingController();

    final url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Import Content',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'Paste Instagram or TikTok link...',
                  prefixIcon: const Icon(Icons.link, color: Color(0xFF7C3AED)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: AppTheme.surface,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(context, urlController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Next Step',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          ),
        ),
      ),
    );

    if (url == null || url.isEmpty) return;
    if (!context.mounted) return;

    // Show language picker (Target Language)
    String selectedLanguage = 'English'; // Default
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguagePickerSheet(
        currentLanguage: selectedLanguage,
        onLanguageSelected: (lang) => selectedLanguage = lang,
      ),
    );

    if (!context.mounted) return;
    
    // Note: Assuming Source is English for now based on requirements.
    // In a future update, we could add a "Source Language" picker too.

    // Show processing screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareProcessingScreen(
          sharedUrl: url,
          initialLanguage: selectedLanguage, // Target: User selection
        ),
      ),
    );

    // If successful, navigate to detail
    if (result != null && result is Memo && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981), // Emerald
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('✨ Memo created successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MemoDetailScreen(memo: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMemos = ref.watch(filteredMemosProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final availableLanguages = ref.watch(availableLanguagesProvider);
    final userName = ref.watch(storageServiceProvider).userName;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text('home.greeting'.tr(args: [userName]), 
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('home.subtitle'.tr(), 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const LanguageSwitcher(),
              const SizedBox(width: 8),
              // Add Memo Button
              InkWell(
                onTap: () => _showAddMemoModal(context, ref),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text('home.memo_button'.tr(), style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'home.search_hint'.tr(),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Language Filter Chips
        if (availableLanguages.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    context,
                    ref,
                    label: 'home.filter_all'.tr(),
                    count: filteredMemos.length,
                    isSelected: selectedLanguage == null,
                    onTap: () {
                      ref.read(selectedLanguageProvider.notifier).state = null;
                    },
                  ),
                ),
                // Language chips
                ...availableLanguages.map((langCount) {
                  final isSelected = selectedLanguage == langCount.language;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      context,
                      ref,
                      emoji: getLanguageFlag(langCount.language),
                      label: getLanguageName(langCount.language),
                      count: langCount.count,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedLanguageProvider.notifier).state = langCount.language;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Memo List
        Expanded(
          child: filteredMemos.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
                  itemCount: filteredMemos.length,
                  cacheExtent: 100, // Pre-cache nearby items for smoother scrolling
                  addAutomaticKeepAlives: true,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final memo = filteredMemos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildMemoCard(context, memo),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    String? emoji,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2962FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.05),
            ),
            child: SizedBox(
              width: 120, 
              height: 120, 
              child: SvgPicture.string(GeneratedArt.emptyMemo),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'home.empty_title'.tr(), 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'home.empty_subtitle'.tr(), 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 100), // padding for the bottom bar
        ],
      ),
    );
  }

  Widget _buildMemoCard(BuildContext context, memo) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemoDetailScreen(memo: memo)),
        );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: memo.thumbnailUrl.startsWith('http') 
              ? Image.network(
                  memo.thumbnailUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  cacheWidth: 200, // Optimize for thumbnail size
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                    );
                  },
                )
              : Image.file(
                  File(memo.thumbnailUrl),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                    );
                  },
                ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  memo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildPlatformIcon(memo.sourcePlatform),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _formatDate(memo.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                  SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionChip(context, 'home.action_see_memo'.tr(), Icons.article, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MemoDetailScreen(memo: memo)),
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionChip(context, 'home.action_cards'.tr(), Icons.style, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FlashcardsScreen(memo: memo)),
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionChip(context, 'home.action_quiz'.tr(), Icons.quiz, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreenMemo(memo: memo)),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformIcon(String platform) {
    IconData icon;
    Color color;
    switch (platform.toLowerCase()) {
      case 'instagram':
        icon = Icons.camera_alt;
        color = const Color(0xFFE1306C);
        break;
      case 'youtube':
        icon = Icons.play_circle_filled;
        color = const Color(0xFFFF0000);
        break;
      case 'tiktok':
        icon = Icons.music_note;
        color = Colors.black;
        break;
      case 'wechat':
        icon = Icons.chat;
        color = const Color(0xFF09B83E);
        break;
      default:
        icon = Icons.link;
        color = Colors.grey;
    }
    return Icon(icon, color: color, size: 16);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(storageServiceProvider).userName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white24, width: 4),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    userName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://docs.google.com/document/d/1j7odriDgA2-mRf7GILQZfzVwqv-kRxj0MSftHoIUb9Y/edit?usp=drivesdk');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  print('Could not launch $url');
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.redeem,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        'profile.claim_rewards'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.1,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('profile.settings_preferences'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildModernListTile(context, 'profile.account_settings'.tr(), 'profile.account_settings_subtitle'.tr(), Icons.manage_accounts, Colors.blue, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsScreen()));
                }),
                _buildModernListTile(context, 'profile.language_target'.tr(), 'profile.language_target_subtitle'.tr(), Icons.language, Colors.green, onTap: () {
                  String currentSelected = ref.read(selectedLanguageProvider) ?? 'English';
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => LanguagePickerSheet(
                      currentLanguage: currentSelected,
                      onLanguageSelected: (lang) {
                        ref.read(selectedLanguageProvider.notifier).state = lang;
                      },
                    ),
                  );
                }),
                _buildModernListTile(context, 'profile.help_center'.tr(), 'profile.help_center_subtitle'.tr(), Icons.help_outline, Colors.purple, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                }),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('profile.log_out_confirm_title'.tr()),
                      content: Text('profile.log_out_confirm_msg'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('profile.cancel'.tr()),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            // Clear all memos
                            ref.read(memosProvider.notifier).clearAll();
                            // Clear shared preferences
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                          },
                          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                          child: Text('profile.log_out_confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, size: 20),
                label: Text('profile.log_out'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error.withOpacity(0.1),
                  foregroundColor: AppTheme.error,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildModernListTile(BuildContext context, String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E293B))),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
          child: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}

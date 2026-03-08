import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/providers/memo_provider.dart';
import '../../../../core/widgets/language_switcher.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(storageServiceProvider).userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('profile.account_settings'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: const [
          LanguageSwitcher(),
          SizedBox(width: 8),
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('profile.profile_section'.tr()),
              _buildSettingsCard([
                _buildListTile(
                  icon: Icons.person,
                  title: 'profile.name'.tr(),
                  trailingText: userName,
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 40),

              Center(
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('profile.delete_account_confirm_title'.tr()),
                        content: Text('profile.delete_account_confirm_msg'.tr()),
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
                              // Navigate back
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                            child: Text('profile.delete_confirm'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('profile.delete_account'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? trailingColor,
    bool showChevron = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 15,
                    color: trailingColor ?? AppTheme.textTertiary,
                    fontWeight: trailingColor != null ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              if (showChevron) ...[
                if (trailingText != null) const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

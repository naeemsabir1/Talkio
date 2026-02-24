import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(storageServiceProvider).userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 for iOS grouped background
      appBar: AppBar(
        title: const Text("Account Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
              _buildSectionHeader("PROFILE"),
              _buildSettingsCard([
                _buildListTile(
                  icon: Icons.person,
                  title: "Name",
                  trailingText: userName,
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 40),

              Center(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Delete Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: Colors.grey.shade100),
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

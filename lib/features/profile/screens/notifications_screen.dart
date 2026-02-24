import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushEnabled = true;
  bool weeklyReport = true;
  bool marketingEmails = false;
  bool newVocabAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
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
              _buildSectionHeader("PUSH NOTIFICATIONS"),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  iconColor: const Color(0xFF8B5CF6),
                  title: "Allow Notifications",
                  subtitle: "Get alerts on your device",
                  value: pushEnabled,
                  onChanged: (val) => setState(() => pushEnabled = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.school,
                  iconColor: const Color(0xFF10B981),
                  title: "Daily Practice Reminders",
                  subtitle: "Don't break your streak",
                  value: newVocabAlerts,
                  onChanged: pushEnabled ? (val) => setState(() => newVocabAlerts = val) : null,
                ),
              ]),
              
              const SizedBox(height: 32),
              
              _buildSectionHeader("EMAIL NOTIFICATIONS"),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.email,
                  iconColor: const Color(0xFF3B82F6),
                  title: "Weekly Progress Report",
                  subtitle: "Your stats sent every Sunday",
                  value: weeklyReport,
                  onChanged: (val) => setState(() => weeklyReport = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.campaign,
                  iconColor: const Color(0xFFF59E0B),
                  title: "News & Special Offers",
                  subtitle: "Updates on new features",
                  value: marketingEmails,
                  onChanged: (val) => setState(() => marketingEmails = val),
                ),
              ]),

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
      padding: const EdgeInsets.only(left: 64),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: onChanged == null ? AppTheme.textTertiary : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

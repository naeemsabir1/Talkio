import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      appBar: AppBar(
        title: const Text("Help Center", style: TextStyle(fontWeight: FontWeight.bold)),
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
              
              // Contact Support Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headset_mic, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "How can we help you?",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Our support team usually replies within 24 hours.",
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showContactSupportModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("Contact Support", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              _buildSectionHeader("FREQUENTLY ASKED"),
              _buildSettingsCard([
                _buildFaqTile(
                  question: "How do I import a video?",
                  answer: "Simply copy the link of any Instagram Reel or TikTok video in your preferred app. Then open Talkio, tap the 'Memo' button on the home screen, paste the URL, and let Talkio automatically extract the audio and transcript for you to learn from.",
                ),
                _buildDivider(),
                _buildFaqTile(
                  question: "How to change translation language?",
                  answer: "When you import a new video, you will be prompted to select a Target Language before processing. You can also update your global default Target Language in the Profile > Language Target settings.",
                ),
                _buildDivider(),
                _buildFaqTile(
                  question: "Why did a video fail to process?",
                  answer: "This usually happens if the link is broken, the video is private, or if the creator has disabled embedding/sharing for that specific video. Try importing a different public video link.",
                ),
              ]),
              
              const SizedBox(height: 32),
              
              _buildSectionHeader("LEGAL"),
              _buildSettingsCard([
                _buildListTile(
                  icon: Icons.shield,
                  title: "Privacy Policy",
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.description,
                  title: "Terms of Service",
                  onTap: () {},
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
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildListTile({
    IconData? icon,
    required String title,
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
              if (icon != null) ...[
                Icon(icon, color: AppTheme.textTertiary, size: 22),
                const SizedBox(width: 16),
              ],
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
              const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          question, 
          style: const TextStyle(
            fontSize: 15, 
            color: AppTheme.textPrimary, 
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: AppTheme.primary,
        collapsedIconColor: AppTheme.textTertiary,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  answer, 
                  style: const TextStyle(
                    fontSize: 14, 
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showContactSupportModal(BuildContext context) {
    showModalBottomSheet(
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                'Contact Support',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Send us a message and we will get back to you soon.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppTheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppTheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppTheme.surface,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message sent successfully!'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Send Message", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

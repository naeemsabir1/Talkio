import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      appBar: AppBar(
        title: Text('help_center.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _buildSectionHeader('help_center.faq_header'.tr()),
              _buildSettingsCard([
                _buildFaqTile(
                  question: 'help_center.faq_q1'.tr(),
                  answer: 'help_center.faq_a1'.tr(),
                ),
                _buildDivider(),
                _buildFaqTile(
                  question: 'help_center.faq_q2'.tr(),
                  answer: 'help_center.faq_a2'.tr(),
                ),
                _buildDivider(),
                _buildFaqTile(
                  question: 'help_center.faq_q3'.tr(),
                  answer: 'help_center.faq_a3'.tr(),
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
}

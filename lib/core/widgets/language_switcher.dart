import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: currentLocale,
          isDense: true,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
          ),
          dropdownColor: AppTheme.surface,
          alignment: Alignment.centerRight,
          items: context.supportedLocales.map((locale) {
            final isSelected = locale == currentLocale;
            return DropdownMenuItem(
              value: locale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getFlag(locale.languageCode), style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    _getLangName(locale.languageCode),
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newLocale) {
            if (newLocale != null) {
              context.setLocale(newLocale);
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return context.supportedLocales.map((locale) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(_getFlag(locale.languageCode), style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    locale.languageCode.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'en': return '🇬🇧'; // Or 🇺🇸
      case 'fr': return '🇫🇷';
      case 'de': return '🇩🇪';
      case 'es': return '🇪🇸';
      case 'it': return '🇮🇹';
      default: return '🇬🇧';
    }
  }

  String _getLangName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      case 'es': return 'Español';
      case 'it': return 'Italiano';
      default: return 'English';
    }
  }
}

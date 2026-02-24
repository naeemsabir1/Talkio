import 'package:flutter/material.dart';
import '../../features/home/widgets/language_picker_sheet.dart';

/// Wrapper around [LanguagePickerSheet] used by `main.dart` for initial setup.
/// Returns the selected language name as a String.
class ImportLanguageSheet extends StatelessWidget {
  const ImportLanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguagePickerSheet(
      currentLanguage: 'English',
      onLanguageSelected: (lang) {
        // Picker already pops with value via _handleSelection
      },
    );
  }
}

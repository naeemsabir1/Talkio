import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memo_model.dart';
import '../services/memo_storage_service.dart';

// Notifier to manage the list of memos with persistence
class MemosNotifier extends StateNotifier<List<Memo>> {
  final MemoStorageService _storage;

  MemosNotifier(this._storage) : super([]) {
    _loadMemos();
  }

  void _loadMemos() {
    state = _storage.getMemos();
  }

  Future<void> refresh() async {
    _loadMemos();
  }
  
  Future<void> deleteMemo(String id) async {
    await _storage.deleteMemo(id);
    _loadMemos();
  }

  Future<void> addMemo(Memo memo) async {
    await _storage.saveMemo(memo);
    _loadMemos();
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
    state = [];
  }
}

// Provider for the list of memos
final memosProvider = StateNotifierProvider<MemosNotifier, List<Memo>>((ref) {
  final storage = ref.watch(memoStorageServiceProvider);
  return MemosNotifier(storage);
});

// Provider for selected language filter (now String-based)
final selectedLanguageProvider = StateProvider<String?>((ref) => null);

// Derived provider that extracts unique languages from memos
final availableLanguagesProvider = Provider<List<LanguageCount>>((ref) {
  final memos = ref.watch(memosProvider);
  final languageCounts = <String, int>{};

  for (var memo in memos) {
    languageCounts[memo.language] = (languageCounts[memo.language] ?? 0) + 1;
  }

  return languageCounts.entries
      .map((e) => LanguageCount(language: e.key, count: e.value))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));
});

// Derived provider for filtered memos
final filteredMemosProvider = Provider<List<Memo>>((ref) {
  final memos = ref.watch(memosProvider);
  final selectedLanguage = ref.watch(selectedLanguageProvider);

  if (selectedLanguage == null) {
    return memos;
  }

  return memos.where((memo) => memo.language == selectedLanguage).toList();
});

class LanguageCount {
  final String language;
  final int count;

  LanguageCount({required this.language, required this.count});
}

// Master language-flag map for the entire app (150+ languages)
const Map<String, String> languageFlags = {
  // Popular / Major
  'English': '🇺🇸', 'Spanish': '🇪🇸', 'French': '🇫🇷', 'Chinese': '🇨🇳',
  'German': '🇩🇪', 'Japanese': '🇯🇵', 'Korean': '🇰🇷', 'Italian': '🇮🇹',
  'Portuguese': '🇵🇹', 'Russian': '🇷🇺', 'Arabic': '🇸🇦', 'Turkish': '🇹🇷',
  'Hindi': '🇮🇳', 'Dutch': '🇳🇱', 'Polish': '🇵🇱', 'Swedish': '🇸🇪',
  'Norwegian': '🇳🇴', 'Danish': '🇩🇰', 'Finnish': '🇫🇮', 'Greek': '🇬🇷',
  'Czech': '🇨🇿', 'Romanian': '🇷🇴', 'Hungarian': '🇭🇺', 'Thai': '🇹🇭',
  'Vietnamese': '🇻🇳', 'Indonesian': '🇮🇩', 'Malay': '🇲🇾', 'Filipino': '🇵🇭',
  'Swahili': '🇰🇪', 'Ukrainian': '🇺🇦', 'Persian': '🇮🇷', 'Hebrew': '🇮🇱',
  // South Asian
  'Bengali': '🇧🇩', 'Tamil': '🇮🇳', 'Telugu': '🇮🇳', 'Urdu': '🇵🇰',
  'Marathi': '🇮🇳', 'Gujarati': '🇮🇳', 'Kannada': '🇮🇳', 'Malayalam': '🇮🇳',
  'Punjabi': '🇮🇳', 'Nepali': '🇳🇵', 'Sinhala': '🇱🇰', 'Assamese': '🇮🇳',
  'Odia': '🇮🇳', 'Sanskrit': '🇮🇳',
  // Southeast Asian
  'Burmese': '🇲🇲', 'Khmer': '🇰🇭', 'Lao': '🇱🇦', 'Mongolian': '🇲🇳',
  'Tetum': '🇹🇱', 'Cebuano': '🇵🇭', 'Tagalog': '🇵🇭', 'Javanese': '🇮🇩',
  'Sundanese': '🇮🇩',
  // East Asian
  'Cantonese': '🇨🇳', 'Taiwanese': '🇹🇼', 'Tibetan': '🌐',
  // European
  'Catalan': '🇪🇸', 'Galician': '🇪🇸', 'Basque': '🇪🇸',
  'Croatian': '🇭🇷', 'Serbian': '🇷🇸', 'Bosnian': '🇧🇦',
  'Slovak': '🇸🇰', 'Slovenian': '🇸🇮', 'Bulgarian': '🇧🇬',
  'Macedonian': '🇲🇰', 'Albanian': '🇦🇱',
  'Latvian': '🇱🇻', 'Lithuanian': '🇱🇹', 'Estonian': '🇪🇪',
  'Icelandic': '🇮🇸', 'Welsh': '🏴', 'Irish': '🇮🇪',
  'Scottish Gaelic': '🏴', 'Breton': '🇫🇷', 'Occitan': '🇫🇷',
  'Corsican': '🇫🇷', 'Luxembourgish': '🇱🇺', 'Maltese': '🇲🇹',
  'Belarusian': '🇧🇾', 'Armenian': '🇦🇲', 'Georgian': '🇬🇪',
  'Azerbaijani': '🇦🇿', 'Kazakh': '🇨🇾', 'Uzbek': '🇺🇿',
  'Turkmen': '🇹🇲', 'Kyrgyz': '🇰🇬', 'Tajik': '🇹🇯',
  'Montenegrin': '🇷🇸', 'Faroese': '🇫🇴', 'Norman': '🇫🇷',
  // African
  'Afrikaans': '🇿🇦', 'Zulu': '🇿🇦', 'Xhosa': '🇿🇦',
  'Sotho': '🇿🇦', 'Tswana': '🇿🇦', 'Yoruba': '🇳🇬',
  'Igbo': '🇳🇬', 'Hausa': '🇳🇬', 'Amharic': '🇪🇹',
  'Tigrinya': '🇪🇷', 'Somali': '🇸🇴', 'Malagasy': '🇲🇬',
  'Kinyarwanda': '🇷🇼', 'Wolof': '🇸🇳', 'Bambara': '🇲🇱',
  'Akan': '🇬🇭', 'Shona': '🇿🇼', 'Tsonga': '🇿🇦',
  'Venda': '🇿🇦', 'Ndebele': '🇿🇦', 'Kirundi': '🇧🇮',
  'Lingala': '🇨🇩', 'Oromo': '🇪🇹',
  // Middle Eastern & Central Asian
  'Kurdish': '🇮🇶', 'Pashto': '🇦🇫', 'Sindhi': '🇮🇳',
  'Kashmiri': '🇮🇳', 'Konkani': '🇮🇳', 'Dogri': '🇮🇳',
  'Maithili': '🇮🇳', 'Manipuri': '🇮🇳', 'Bodo': '🇮🇳', 'Santali': '🇮🇳',
  // Pacific & Oceanic
  'Maori': '🇳🇿', 'Fijian': '🇫🇯', 'Samoan': '🇼🇸',
  'Tongan': '🇹🇴', 'Hawaiian': '🇭🇮', 'Tok Pisin': '🇵🇬',
  // Americas
  'Guarani': '🇵🇾', 'Quechua': '🇧🇴', 'Aymara': '🇧🇴',
  'Nahuatl': '🇲🇽', "K'iche'": '🇬🇹', 'Inuktitut': '🇨🇦',
  'Navajo': '🇺🇸', 'Cherokee': '🇺🇸', 'Haitian Creole': '🇭🇹',
  // Constructed & Classical
  'Esperanto': '🌐', 'Latin': '🌐', 'Interlingua': '🌐',
  // Additional
  'Sudanese Arabic': '🇸🇩', 'Libyan Arabic': '🇱🇾',
  'Moroccan Arabic': '🇲🇦', 'Egyptian Arabic': '🇪🇬',
  'Levantine Arabic': '🇱🇧',
  'Minangkabau': '🇮🇩', 'Balinese': '🇮🇩',
  'Ilocano': '🇵🇭', 'Hiligaynon': '🇵🇭', 'Waray': '🇵🇭',
  'Trinidad Creole': '🇹🇹', 'Jamaican Patois': '🇯🇲',
  'Papiamento': '🇨🇼', 'Sranan Tongo': '🇸🇷',
  'Dhivehi': '🇲🇻', 'Dzongkha': '🇧🇹', 'Buryat': '🇲🇳',
  'Tatar': '🇷🇺', 'Bashkir': '🇷🇺', 'Chuvash': '🇷🇺',
  'Chechen': '🇷🇺', 'Uyghur': '🇨🇳', 'Tamil (Sri Lankan)': '🇱🇰',
};

/// Get the flag emoji for a language name. Falls back to globe emoji.
String getLanguageFlag(String language) {
  return languageFlags[language] ?? '🌐';
}

/// Get language name — now just a passthrough since language is a String.
String getLanguageName(String language) {
  return language;
}

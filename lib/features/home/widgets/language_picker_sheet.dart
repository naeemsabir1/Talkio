import 'package:flutter/material.dart';
import 'dart:ui';

class LanguagePickerSheet extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;

  const LanguagePickerSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Master language list (150+) ─────────────────────────────
  static const List<_LangEntry> _allLanguages = [
    // ── Popular / Major Languages ──────────────────────────
    _LangEntry('🇺🇸', 'English'),
    _LangEntry('🇪🇸', 'Spanish'),
    _LangEntry('🇫🇷', 'French'),
    _LangEntry('🇨🇳', 'Chinese'),
    _LangEntry('🇩🇪', 'German'),
    _LangEntry('🇯🇵', 'Japanese'),
    _LangEntry('🇰🇷', 'Korean'),
    _LangEntry('🇮🇳', 'Hindi'),
    _LangEntry('🇮🇹', 'Italian'),
    _LangEntry('🇵🇹', 'Portuguese'),
    _LangEntry('🇷🇺', 'Russian'),
    _LangEntry('🇸🇦', 'Arabic'),
    _LangEntry('🇹🇷', 'Turkish'),
    _LangEntry('🇳🇱', 'Dutch'),
    _LangEntry('🇵🇱', 'Polish'),
    _LangEntry('🇸🇪', 'Swedish'),
    _LangEntry('🇳🇴', 'Norwegian'),
    _LangEntry('🇩🇰', 'Danish'),
    _LangEntry('🇫🇮', 'Finnish'),
    _LangEntry('🇬🇷', 'Greek'),
    _LangEntry('🇨🇿', 'Czech'),
    _LangEntry('🇷🇴', 'Romanian'),
    _LangEntry('🇭🇺', 'Hungarian'),
    _LangEntry('🇹🇭', 'Thai'),
    _LangEntry('🇻🇳', 'Vietnamese'),
    _LangEntry('🇮🇩', 'Indonesian'),
    _LangEntry('🇲🇾', 'Malay'),
    _LangEntry('🇵🇭', 'Filipino'),
    _LangEntry('🇰🇪', 'Swahili'),
    _LangEntry('🇺🇦', 'Ukrainian'),
    _LangEntry('🇮🇷', 'Persian'),
    _LangEntry('🇮🇱', 'Hebrew'),
    // ── South Asian Languages ──────────────────────────────
    _LangEntry('🇧🇩', 'Bengali'),
    _LangEntry('🇮🇳', 'Tamil'),
    _LangEntry('🇮🇳', 'Telugu'),
    _LangEntry('🇵🇰', 'Urdu'),
    _LangEntry('🇮🇳', 'Marathi'),
    _LangEntry('🇮🇳', 'Gujarati'),
    _LangEntry('🇮🇳', 'Kannada'),
    _LangEntry('🇮🇳', 'Malayalam'),
    _LangEntry('🇮🇳', 'Punjabi'),
    _LangEntry('🇳🇵', 'Nepali'),
    _LangEntry('🇱🇰', 'Sinhala'),
    _LangEntry('🇮🇳', 'Assamese'),
    _LangEntry('🇮🇳', 'Odia'),
    _LangEntry('🇮🇳', 'Sanskrit'),
    // ── Southeast Asian Languages ──────────────────────────
    _LangEntry('🇲🇲', 'Burmese'),
    _LangEntry('🇰🇭', 'Khmer'),
    _LangEntry('🇱🇦', 'Lao'),
    _LangEntry('🇲🇳', 'Mongolian'),
    _LangEntry('🇹🇱', 'Tetum'),
    _LangEntry('🇵🇭', 'Cebuano'),
    _LangEntry('🇵🇭', 'Tagalog'),
    _LangEntry('🇮🇩', 'Javanese'),
    _LangEntry('🇮🇩', 'Sundanese'),
    // ── East Asian Languages ───────────────────────────────
    _LangEntry('🇨🇳', 'Cantonese'),
    _LangEntry('🇹🇼', 'Taiwanese'),
    _LangEntry('🇹🇮🇧', 'Tibetan'),
    // ── European Languages ─────────────────────────────────
    _LangEntry('🇪🇸', 'Catalan'),
    _LangEntry('🇪🇸', 'Galician'),
    _LangEntry('🇪🇸', 'Basque'),
    _LangEntry('🇭🇷', 'Croatian'),
    _LangEntry('🇷🇸', 'Serbian'),
    _LangEntry('🇧🇦', 'Bosnian'),
    _LangEntry('🇸🇰', 'Slovak'),
    _LangEntry('🇸🇮', 'Slovenian'),
    _LangEntry('🇧🇬', 'Bulgarian'),
    _LangEntry('🇲🇰', 'Macedonian'),
    _LangEntry('🇦🇱', 'Albanian'),
    _LangEntry('🇱🇻', 'Latvian'),
    _LangEntry('🇱🇹', 'Lithuanian'),
    _LangEntry('🇪🇪', 'Estonian'),
    _LangEntry('🇮🇸', 'Icelandic'),
    _LangEntry('🏴', 'Welsh'),
    _LangEntry('🇮🇪', 'Irish'),
    _LangEntry('🏴', 'Scottish Gaelic'),
    _LangEntry('🇫🇷', 'Breton'),
    _LangEntry('🇫🇷', 'Occitan'),
    _LangEntry('🇫🇷', 'Corsican'),
    _LangEntry('🇱🇺', 'Luxembourgish'),
    _LangEntry('🇲🇹', 'Maltese'),
    _LangEntry('🇧🇾', 'Belarusian'),
    _LangEntry('🇦🇲', 'Armenian'),
    _LangEntry('🇬🇪', 'Georgian'),
    _LangEntry('🇦🇿', 'Azerbaijani'),
    _LangEntry('🇨🇾', 'Kazakh'),
    _LangEntry('🇺🇿', 'Uzbek'),
    _LangEntry('🇹🇲', 'Turkmen'),
    _LangEntry('🇰🇬', 'Kyrgyz'),
    _LangEntry('🇹🇯', 'Tajik'),
    _LangEntry('🇷🇸', 'Montenegrin'),
    _LangEntry('🇵🇹', 'Galician'),
    _LangEntry('🇫🇴', 'Faroese'),
    _LangEntry('🇫🇷', 'Norman'),
    // ── African Languages ──────────────────────────────────
    _LangEntry('🇿🇦', 'Afrikaans'),
    _LangEntry('🇿🇦', 'Zulu'),
    _LangEntry('🇿🇦', 'Xhosa'),
    _LangEntry('🇿🇦', 'Sotho'),
    _LangEntry('🇿🇦', 'Tswana'),
    _LangEntry('🇳🇬', 'Yoruba'),
    _LangEntry('🇳🇬', 'Igbo'),
    _LangEntry('🇳🇬', 'Hausa'),
    _LangEntry('🇪🇹', 'Amharic'),
    _LangEntry('🇪🇷', 'Tigrinya'),
    _LangEntry('🇸🇴', 'Somali'),
    _LangEntry('🇲🇬', 'Malagasy'),
    _LangEntry('🇷🇼', 'Kinyarwanda'),
    _LangEntry('🇸🇳', 'Wolof'),
    _LangEntry('🇹🇿', 'Swahili'),
    _LangEntry('🇲🇱', 'Bambara'),
    _LangEntry('🇬🇭', 'Akan'),
    _LangEntry('🇿🇼', 'Shona'),
    _LangEntry('🇿🇦', 'Tsonga'),
    _LangEntry('🇿🇦', 'Venda'),
    _LangEntry('🇿🇦', 'Ndebele'),
    _LangEntry('🇧🇮', 'Kirundi'),
    _LangEntry('🇲🇿', 'Tsonga'),
    _LangEntry('🇨🇩', 'Lingala'),
    // ── Middle Eastern & Central Asian ─────────────────────
    _LangEntry('🇮🇶', 'Kurdish'),
    _LangEntry('🇦🇫', 'Pashto'),
    _LangEntry('🇮🇳', 'Sindhi'),
    _LangEntry('🇮🇳', 'Kashmiri'),
    _LangEntry('🇮🇳', 'Konkani'),
    _LangEntry('🇮🇳', 'Dogri'),
    _LangEntry('🇮🇳', 'Maithili'),
    _LangEntry('🇮🇳', 'Manipuri'),
    _LangEntry('🇮🇳', 'Bodo'),
    _LangEntry('🇮🇳', 'Santali'),
    // ── Pacific & Oceanic Languages ───────────────────────
    _LangEntry('🇳🇿', 'Maori'),
    _LangEntry('🇫🇯', 'Fijian'),
    _LangEntry('🇼🇸', 'Samoan'),
    _LangEntry('🇹🇴', 'Tongan'),
    _LangEntry('🇭🇮', 'Hawaiian'),
    _LangEntry('🇵🇬', 'Tok Pisin'),
    // ── Americas ──────────────────────────────────────────
    _LangEntry('🇵🇾', 'Guarani'),
    _LangEntry('🇧🇴', 'Quechua'),
    _LangEntry('🇧🇴', 'Aymara'),
    _LangEntry('🇲🇽', 'Nahuatl'),
    _LangEntry('🇬🇹', 'K\'iche\''),
    _LangEntry('🇨🇦', 'Inuktitut'),
    _LangEntry('🇺🇸', 'Navajo'),
    _LangEntry('🇺🇸', 'Cherokee'),
    _LangEntry('🇭🇹', 'Haitian Creole'),
    // ── Constructed & Classical ────────────────────────────
    _LangEntry('🌐', 'Esperanto'),
    _LangEntry('🌐', 'Latin'),
    _LangEntry('🌐', 'Interlingua'),
    // ── Additional Languages ──────────────────────────────
    _LangEntry('🇪🇹', 'Oromo'),
    _LangEntry('🇸🇩', 'Sudanese Arabic'),
    _LangEntry('🇱🇾', 'Libyan Arabic'),
    _LangEntry('🇲🇦', 'Moroccan Arabic'),
    _LangEntry('🇪🇬', 'Egyptian Arabic'),
    _LangEntry('🇱🇧', 'Levantine Arabic'),
    _LangEntry('🇮🇩', 'Minangkabau'),
    _LangEntry('🇮🇩', 'Balinese'),
    _LangEntry('🇵🇭', 'Ilocano'),
    _LangEntry('🇵🇭', 'Hiligaynon'),
    _LangEntry('🇵🇭', 'Waray'),
    _LangEntry('🇹🇹', 'Trinidad Creole'),
    _LangEntry('🇯🇲', 'Jamaican Patois'),
    _LangEntry('🇨🇼', 'Papiamento'),
    _LangEntry('🇸🇷', 'Sranan Tongo'),
    _LangEntry('🇲🇻', 'Dhivehi'),
    _LangEntry('🇧🇹', 'Dzongkha'),
    _LangEntry('🇲🇳', 'Buryat'),
    _LangEntry('🇷🇺', 'Tatar'),
    _LangEntry('🇷🇺', 'Bashkir'),
    _LangEntry('🇷🇺', 'Chuvash'),
    _LangEntry('🇷🇺', 'Chechen'),
    _LangEntry('🇨🇳', 'Uyghur'),
    _LangEntry('🇱🇰', 'Tamil (Sri Lankan)'),
  ];

  List<_LangEntry> get _filteredLanguages {
    if (_searchQuery.isEmpty) return _allLanguages;
    final q = _searchQuery.toLowerCase();
    return _allLanguages.where((l) => l.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLanguages;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.85),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
              ),
            ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Beautiful glowing handle bar
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Header section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Language',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'For translation, summary & grammar',
                            style: TextStyle(
                              color: Color(0xFF94A3B8), // slate 400
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // ── Stunning Search Bar ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty 
                          ? const Color(0xFF8B5CF6).withOpacity(0.5) 
                          : Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                    boxShadow: _searchQuery.isNotEmpty ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.15),
                        blurRadius: 16,
                        spreadRadius: -2,
                      )
                    ] : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
                    cursorColor: const Color(0xFF8B5CF6),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
                      suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.cancel, color: Color(0xFF94A3B8), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      hintText: 'Search 150+ languages...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 16, fontFamily: 'Inter'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              
              // Gradient divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 4),
              
              // ── Language List ─────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.travel_explore, color: Color(0xFF64748B), size: 48),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Language not found',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching with a different term.',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final lang = filtered[index];
                          final isSelected = widget.currentLanguage == lang.name;
                          return _LanguageItem(
                            flag: lang.flag,
                            name: lang.name,
                            isSelected: isSelected,
                            onTap: () => _handleSelection(context, lang.name),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  void _handleSelection(BuildContext context, String language) {
    widget.onLanguageSelected(language);
    Navigator.pop(context, language); // Pop WITH value for .then() callers
  }
}

// ── Private data class ──────────────────────────────────────────
class _LangEntry {
  final String flag;
  final String name;
  const _LangEntry(this.flag, this.name);
}

// ── Language item widget ────────────────────────────────────────
class _LanguageItem extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.flag,
    required this.name,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF8B5CF6).withOpacity(0.2),
          highlightColor: const Color(0xFF8B5CF6).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Text(flag, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  )
                else
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

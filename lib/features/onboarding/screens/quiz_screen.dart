import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../assets/generated_art.dart';
import '../../../core/widgets/glass_card.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final int _totalPages = 9;
  String? _selectedOption;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.push('/pitch');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage > 0) {
              _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              context.pop();
            }
          },
        ),
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: LinearPercentIndicator(
            width: 200,
            lineHeight: 8.0,
            percent: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.white12,
            progressColor: AppTheme.primary,
            barRadius: const Radius.circular(4),
            animation: true,
            animationDuration: 500,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC), // God Mode Light Slate
      body: Stack(
        children: [
          // Subtle Light Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.08),
                    const Color(0xFF3B82F6).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
             bottom: -100,
             left: -100,
             child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.05),
                    const Color(0xFFEC4899).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                // 1. Language
                _buildExpandedLanguagePage(notifier),
                // 2. Improvement Goal
                _buildAnimatedListPage(
                  "What part do you want\nto improve?",
                  svg: GeneratedArt.wavingGirl,
                  options: ["Speaking", "Pronunciation", "Vocabulary", "Grammar"],
                  onSelect: (val) {
                    notifier.setImprovementGoal(val);
                    _nextPage();
                  },
                ),
                // 3. Main Goal
                _buildAnimatedListPage(
                  "What is your main goal?",
                  options: ["Work", "New Job", "Live Abroad", "Travel"],
                  onSelect: (val) {
                    notifier.setMainGoal(val);
                    _nextPage();
                  },
                ),
                // 4. Barriers (Multi)
                _buildGlassMultiSelectPage(
                  "What's stopping you?",
                  options: ["I freeze when speaking", "Can't express myself", "My accent", "Can't reply quickly"],
                  selected: state.barriers,
                  onToggle: notifier.toggleBarrier,
                  onNext: _nextPage,
                ),
                // 5. Agree (Confidence)
                _buildConfidencePage(
                  "I know exactly what to say...\nbut can't find the words.",
                  state,
                  notifier,
                ),
                // 6. Daily Usage (Multi)
                _buildGlassMultiSelectPage(
                  "How do you use English?",
                  options: ["News", "TV Shows / Movies", "Music", "Work"],
                  selected: state.dailyUsage,
                  onToggle: notifier.toggleDailyUsage,
                  onNext: _nextPage,
                ),
                // 7. Demographics
                _buildDemographicsPage(state, notifier),
                // 8. Methods (Multi)
                _buildGlassMultiSelectPage(
                  "How are you currently\nimproving?",
                  options: ["Classes", "Apps", "Movies/TV", "Books"],
                  selected: state.methods,
                  onToggle: notifier.toggleMethod,
                  onNext: _nextPage,
                ),
                // 9. Challenges
                _buildGlassMultiSelectPage(
                  "What are your main\nchallenges?",
                  options: ["Lack of Time", "Motivation", "Nervousness"],
                  selected: state.challenges,
                  onToggle: notifier.toggleChallenge,
                  onNext: _nextPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton({required bool isEnabled, required VoidCallback onNext}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppTheme.primary : AppTheme.primary.withOpacity(0.1),
          disabledBackgroundColor: Colors.white.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isEnabled ? BorderSide(color: AppTheme.primary.withOpacity(0.5), width: 1.5) : BorderSide(color: Colors.white.withOpacity(0.1), width: 1.0),
          ),
          elevation: isEnabled ? 8 : 0,
        ),
        child: Text(
          "Continue",
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white.withOpacity(0.3),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // --- EXPANDED LANGUAGE PAGE (20+ LANGUAGES) ---
  Widget _buildExpandedLanguagePage(QuizNotifier notifier) {
    final languages = [
      "🇬🇧 English", "🇪🇸 Spanish", "🇫🇷 French", "🇩🇪 German",
      "🇯🇵 Japanese", "🇨🇳 Chinese", "🇰🇷 Korean", "🇮🇹 Italian",
      "🇵🇹 Portuguese", "🇷🇺 Russian", "🇸🇦 Arabic", "🇹🇷 Turkish",
      "🇮🇳 Hindi", "🇵🇰 Urdu", "🇳🇱 Dutch", "🇸🇪 Swedish",
      "🇵🇱 Polish", "🇻🇳 Vietnamese", "🇹🇭 Thai", "🇬🇷 Greek",
      "🌐 Other / Auto-Detect"
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            "What language do you\nwant to learn?",
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = _selectedOption == lang;
                
                return _AnimatedLanguageCard(
                  label: lang,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedOption = lang);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      notifier.setLanguage(lang);
                      _nextPage();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ANIMATED LIST PAGE (WITH GLASS CARDS) ---
  Widget _buildAnimatedListPage(
    String title, {
    String? svg,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (svg != null) SizedBox(height: 150, child: SvgPicture.string(svg)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: options.asMap().entries.map((entry) {
                  final opt = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BouncyOptionButton(
                      label: opt,
                      onTap: () => onSelect(opt),
                      delay: entry.key * 50,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- GLASS MULTI-SELECT PAGE ---
  Widget _buildGlassMultiSelectPage(
    String title, {
    required List<String> options,
    required List<String> selected,
    required Function(String) onToggle,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final opt = options[index];
                final isSelected = selected.contains(opt);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    onTap: () => onToggle(opt),
                    backgroundColor: isSelected 
                      ? const Color(0xFF8B5CF6).withOpacity(0.1)
                      : Colors.white,
                    borderColor: isSelected
                      ? const Color(0xFF8B5CF6)
                      : Colors.black.withOpacity(0.05),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF334155),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Color(0xFF8B5CF6)), // Colored icon
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildContinueButton(
            isEnabled: selected.isNotEmpty,
            onNext: onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidencePage(String title, QuizState state, QuizNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 200, child: SvgPicture.string(GeneratedArt.thinkingGirl)),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["No", "Maybe", "Yes"].map((opt) {
              final isSelected = state.wordConfidence == opt;
              return GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                onTap: () {
                  notifier.setWordConfidence(opt);
                  _nextPage();
                },
                backgroundColor: isSelected
                    ? const Color(0xFF8B5CF6).withOpacity(0.1)
                    : Colors.white,
                borderColor: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.black.withOpacity(0.05),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF334155),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildDemographicsPage(QuizState state, QuizNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text("Tell us about yourself", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          GlassCard(
            backgroundColor: Colors.white,
            borderColor: Colors.black.withOpacity(0.05),
            child: Column(
              children: [
                Text("Age: ${state.age.round()}", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF1E293B))),
                Slider(
                  value: state.age,
                  min: 14,
                  max: 70,
                  divisions: 56,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.primary.withOpacity(0.2),
                  onChanged: (val) => notifier.setAge(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            backgroundColor: Colors.white,
            borderColor: Colors.black.withOpacity(0.05),
            child: Column(
              children: [
                Text("Gender", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF1E293B))),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: ["Female", "Male"].map((g) {
                    final isSelected = state.gender == g;
                    return ChoiceChip(
                      label: Text(g, style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      )),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : Colors.black.withOpacity(0.1),
                      ),
                      onSelected: (_) => notifier.setGender(g),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildContinueButton(
            isEnabled: state.gender?.isNotEmpty ?? false,
            onNext: _nextPage,
          ),
        ],
      ),
    );
  }
}

// --- ANIMATED LANGUAGE CARD ---
class _AnimatedLanguageCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedLanguageCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.black.withOpacity(0.05),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF334155),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// --- BOUNCY OPTION BUTTON ---
class _BouncyOptionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final int delay;

  const _BouncyOptionButton({
    required this.label,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<_BouncyOptionButton> createState() => _BouncyOptionButtonState();
}

class _BouncyOptionButtonState extends State<_BouncyOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isTapped = true);
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        widget.onTap();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GlassCard(
        onTap: _handleTap,
        backgroundColor: Colors.white,
        borderColor: Colors.black.withOpacity(0.05),
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class to hold quiz answers
class QuizState {
  final String? language;
  final String? improvementGoal;
  final String? mainGoal;
  final List<String> barriers;
  final String? wordConfidence; // Yes/Maybe/No
  final List<String> dailyUsage;
  final double age;
  final String? gender;
  final List<String> methods;
  final List<String> challenges;

  QuizState({
    this.language,
    this.improvementGoal,
    this.mainGoal,
    this.barriers = const [],
    this.wordConfidence,
    this.dailyUsage = const [],
    this.age = 25,
    this.gender,
    this.methods = const [],
    this.challenges = const [],
  });

  QuizState copyWith({
    String? language,
    String? improvementGoal,
    String? mainGoal,
    List<String>? barriers,
    String? wordConfidence,
    List<String>? dailyUsage,
    double? age,
    String? gender,
    List<String>? methods,
    List<String>? challenges,
  }) {
    return QuizState(
      language: language ?? this.language,
      improvementGoal: improvementGoal ?? this.improvementGoal,
      mainGoal: mainGoal ?? this.mainGoal,
      barriers: barriers ?? this.barriers,
      wordConfidence: wordConfidence ?? this.wordConfidence,
      dailyUsage: dailyUsage ?? this.dailyUsage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      methods: methods ?? this.methods,
      challenges: challenges ?? this.challenges,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState());

  void setLanguage(String val) => state = state.copyWith(language: val);
  void setImprovementGoal(String val) => state = state.copyWith(improvementGoal: val);
  void setMainGoal(String val) => state = state.copyWith(mainGoal: val);
  void toggleBarrier(String val) => _toggleList(val, state.barriers, (l) => state = state.copyWith(barriers: l));
  void setWordConfidence(String val) => state = state.copyWith(wordConfidence: val);
  void toggleDailyUsage(String val) => _toggleList(val, state.dailyUsage, (l) => state = state.copyWith(dailyUsage: l));
  void setAge(double val) => state = state.copyWith(age: val);
  void setGender(String val) => state = state.copyWith(gender: val);
  void toggleMethod(String val) => _toggleList(val, state.methods, (l) => state = state.copyWith(methods: l));
  void toggleChallenge(String val) => _toggleList(val, state.challenges, (l) => state = state.copyWith(challenges: l));

  void _toggleList(String val, List<String> current, Function(List<String>) update) {
    final list = List<String>.from(current);
    if (list.contains(val)) {
      list.remove(val);
    } else {
      list.add(val);
    }
    update(list);
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});

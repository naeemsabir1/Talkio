import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/memo_model.dart';
import '../../features/onboarding/screens/landing_screen.dart';
import '../../features/onboarding/screens/quiz_screen.dart';
import '../../features/onboarding/screens/pitch_screen.dart';
import '../../features/onboarding/screens/tutorial_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/share_processing_screen.dart';
import '../../features/memo/screens/memo_detail_screen.dart';
import '../../features/premium/screens/onboarding_paywall_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(storageServiceProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (storage.isOnboardingComplete) {
             return const HomeScreen();
          } else {
             return const LandingScreen();
          }
        },
      ),
      GoRoute(
        path: '/processing',
        builder: (context, state) {
          final params = state.extra as Map<String, String>?;
          return ShareProcessingScreen(
            sharedUrl: params?['url'] ?? '',
            initialLanguage: params?['language'],
          );
        },
      ),
      GoRoute(
        path: '/memo/:id',
        builder: (context, state) {
          final memo = state.extra as Memo;
          return MemoDetailScreen(memo: memo);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/pitch',
        builder: (context, state) => const PitchScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/onboarding_paywall',
        builder: (context, state) => const OnboardingPaywallScreen(),
      ),
    ],
  );
});

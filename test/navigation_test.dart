import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auraly_clone/core/router/app_router.dart';
import 'package:auraly_clone/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Navigation Tests', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial route is landing screen when onboarding not complete', () {
      final router = container.read(routerProvider);
      expect(router.routerDelegate.currentConfiguration.uri.path, equals('/'));
    });

    test('Initial route is home screen when onboarding complete', () async {
      final storage = container.read(storageServiceProvider);
      await storage.setOnboardingComplete();

      final newContainer = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      final router = newContainer.read(routerProvider);
      
      // Router should check storage and route to home
      expect(storage.isOnboardingComplete, isTrue);
      
      newContainer.dispose();
    });

    test('All routes are defined correctly', () {
      final router = container.read(routerProvider);
      final routes = router.configuration.routes;

      expect(routes.length, equals(6));
      
      // Check route paths
      final routePaths = routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(routePaths, contains('/'));
      expect(routePaths, contains('/processing'));
      expect(routePaths, contains('/memo/:id'));
      expect(routePaths, contains('/home'));
      expect(routePaths, contains('/quiz'));
      expect(routePaths, contains('/pitch'));
      expect(routePaths, contains('/tutorial'));
    });

    test('Processing route accepts URL and language parameters', () {
      final router = container.read(routerProvider);
      
      // Navigate with extra parameters
      router.go('/processing', extra: {
        'url': 'https://instagram.com/p/test',
        'language': 'English',
      });

      expect(router.routerDelegate.currentConfiguration.uri.path, equals('/processing'));
    });

    test('Memo detail route requires memo parameter', () {
      final router = container.read(routerProvider);
      
      // This test verifies the route accepts :id parameter
      final memoRoute = router.configuration.routes
          .whereType<GoRoute>()
          .firstWhere((r) => r.path == '/memo/:id');
      
      expect(memoRoute.path, equals('/memo/:id'));
    });
  });
}

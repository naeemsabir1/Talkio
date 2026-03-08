import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/memo_storage_service.dart';
import 'features/home/screens/share_processing_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/services/revenuecat_service.dart';
import 'features/premium/screens/paywall_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        Locale('it'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
          memoStorageServiceProvider.overrideWithValue(MemoStorageService(prefs)),
        ],
        child: const TalkioApp(),
      ),
    ),
  );
}

class TalkioApp extends ConsumerStatefulWidget {
  const TalkioApp({super.key});

  @override
  ConsumerState<TalkioApp> createState() => _TalkioAppState();
}

class _TalkioAppState extends ConsumerState<TalkioApp> {
  StreamSubscription? _intentDataStreamSubscription;
  bool _hasCheckedInitial = false;
  bool _isNavigatingToShare = false; // Prevent duplicate navigations

  @override
  void initState() {
    super.initState();
    _initializeShareIntentListeners();
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    final revenueCat = ref.read(revenueCatServiceProvider);
    await revenueCat.initialize();
  }

  void _initializeShareIntentListeners() {
    debugPrint('🔧 ShareIntent: Initializing listeners...');
    
    // 🔥 COLD START: Check for initial shared text when app launched via share
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasCheckedInitial && mounted) {
        _hasCheckedInitial = true;
        
        // Give the app a moment to settle
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (!mounted) return;
        
        debugPrint('🔧 ShareIntent: Checking for initial shared media (cold start)...');
        
        try {
          final List<SharedMediaFile> value = await ReceiveSharingIntent.instance.getInitialMedia();
          debugPrint('🔧 ShareIntent: getInitialMedia returned ${value.length} items');
          
          if (value.isNotEmpty && mounted) {
            final firstFile = value.first;
            final possibleUrl = firstFile.path;
            debugPrint('🎯 COLD START: Received share path: "$possibleUrl"');
            debugPrint('🎯 COLD START: File type: ${firstFile.type}');
            
            if (possibleUrl.isNotEmpty) {
              _handleSharedUrl(possibleUrl);
            } else {
              debugPrint('⚠️ ShareIntent: path is empty, ignoring');
            }
          } else {
            debugPrint('📱 Normal app launch (no initial media)');
          }
        } catch (err) {
          debugPrint('❌ Error getting initial media: $err');
        }
      }
    });

    // 🔥 WARM START: Listen for shares while app is already running
    debugPrint('🔧 ShareIntent: Setting up warm-start media stream listener...');
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        debugPrint('🔥 WARM START: getMediaStream fired with ${value.length} items');
        if (value.isNotEmpty && mounted) {
          final firstFile = value.first;
          final possibleUrl = firstFile.path;
          debugPrint('🔥 WARM START: path: "$possibleUrl"');
          debugPrint('🔥 WARM START: type: ${firstFile.type}');
          
          if (possibleUrl.isNotEmpty) {
            _handleSharedUrl(possibleUrl);
          }
        }
      },
      onError: (err) {
        debugPrint('❌ Share intent stream error: $err');
      },
    );
  }

  void _handleSharedUrl(String url, [int retryCount = 0]) {
    debugPrint('📤 _handleSharedUrl called: "$url" (retry: $retryCount)');
    
    // Prevent duplicate navigations
    if (_isNavigatingToShare) {
      debugPrint('⚠️ Already navigating to share screen, skipping duplicate');
      return;
    }
    
    // Safety limit on retries
    if (retryCount > 5) {
      debugPrint('❌ Max retries reached for share navigation, giving up');
      return;
    }
    
    // Use rootNavigatorKey.currentState for reliable navigation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final navigatorState = rootNavigatorKey.currentState;
      if (navigatorState == null) {
        debugPrint('⚠️ Navigator state is null, retrying in 500ms (attempt ${retryCount + 1})...');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _handleSharedUrl(url, retryCount + 1);
        });
        return;
      }
      
      _isNavigatingToShare = true;

      // Premium hard-lock check
      final revenueCat = ref.read(revenueCatServiceProvider);
      if (!revenueCat.isPremiumUser()) {
         debugPrint('🔒 User is not premium, routing to Paywall');
         final purchased = await navigatorState.push(
           MaterialPageRoute(
             builder: (context) => const PaywallScreen(),
             fullscreenDialog: true,
           ),
         );
         _isNavigatingToShare = false;
         if (purchased == true && mounted) {
           _handleSharedUrl(url, 0); // Retry sharing logic now that user is premium
         }
         return; // Drop share attempt if they didn't purchase
      }
      
      debugPrint('✅ Navigating to ShareProcessingScreen with URL: $url');
      
      navigatorState.push(
        MaterialPageRoute(
          builder: (context) => ShareProcessingScreen(sharedUrl: url),
          fullscreenDialog: true,
        ),
      ).then((_) {
        // Reset flag when share screen is popped
        _isNavigatingToShare = false;
        debugPrint('🔙 Returned from ShareProcessingScreen');
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Talkio',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Enforce God Mode
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

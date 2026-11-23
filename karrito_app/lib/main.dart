import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/services/subscription_service.dart';
import 'data/services/sync_service.dart';
import 'providers/core_providers.dart';
import 'providers/shopping_providers.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/shopping_list_screen.dart';
import 'ui/widgets/karrito_asset_icon.dart';
import 'ui/widgets/karrito_toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Never let an uncaught background SDK or framework error kill the UI loop.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Karrito FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Karrito unhandled async error: $error');
    return true;
  };

  // Start rendering local Drift UI + Electric Mercado theme immediately without
  // blocking the first frame on Firebase, AdMob, RevenueCat, or Supabase.
  runApp(const ProviderScope(child: KarritoApp()));
}

class KarritoApp extends ConsumerStatefulWidget {
  const KarritoApp({super.key});

  @override
  ConsumerState<KarritoApp> createState() => _KarritoAppState();
}

class _KarritoAppState extends ConsumerState<KarritoApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool? _lastOnline;
  bool? _lastKeepScreenOn;
  RealtimeChannel? _realtimeChannel;
  String? _realtimeListId;
  SyncService? _syncService;

  @override
  void initState() {
    super.initState();
    unawaited(KarritoAssetRegistry.warmUp());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_initializeDeferredServices());
    });
  }

  /// Initializes external SDKs asynchronously after the first local Drift frame
  /// renders, isolating every SDK in its own `try / catch` block so no external
  /// service can ever block or crash app startup.
  Future<void> _initializeDeferredServices() async {
    // 1. Firebase / FCM (independent)
    unawaited(() async {
      try {
        if (!mounted) return;
        await ref.read(pushNotificationServiceProvider).initializeSafely();
      } catch (e) {
        debugPrint('Karrito deferred Firebase init skipped: $e');
      }
    }());

    // 2. Google Mobile Ads (independent)
    unawaited(() async {
      try {
        if (!mounted) return;
        await ref.read(adsCascadeServiceProvider).initializeMobileAdsSafely();
      } catch (e) {
        debugPrint('Karrito deferred MobileAds init skipped: $e');
      }
    }());

    // 3. Supabase (independent, unlocks sync/auth/ads refresh)
    try {
      final ready = await ref.read(supabaseInitializerProvider)();
      if (!mounted) return;
      if (ready && ref.read(supabaseClientProvider) == null) {
        ref.invalidate(supabaseClientProvider);
      }
    } catch (e) {
      debugPrint('Karrito deferred Supabase init skipped: $e');
    }

    if (!mounted) return;
    _syncService = ref.read(syncServiceProvider);
    _handleOnlineState(ref.read(isOnlineProvider));
    _updateRealtimeSubscription(
      isOnline: ref.read(isOnlineProvider),
      activeList: ref.read(activeListProvider),
    );
  }

  @override
  void dispose() {
    KarritoToast.dismissCurrent();
    final channel = _realtimeChannel;
    final sync = _syncService;
    _realtimeChannel = null;
    if (channel != null && sync != null) {
      unawaited(sync.unsubscribeChannel(channel));
    }
    super.dispose();
  }

  void _handleOnlineState(bool isOnline) {
    final wasOnline = _lastOnline;
    _lastOnline = isOnline;
    if (!isOnline) {
      _updateRealtimeSubscription(
        isOnline: false,
        activeList: ref.read(activeListProvider),
      );
      return;
    }

    if (wasOnline != true) {
      unawaited(_bootstrapOnlineSync());
    }
  }

  Future<void> _bootstrapOnlineSync() async {
    String? currentUserId;
    try {
      final auth = ref.read(authServiceProvider);
      await auth.ensureSignedInSilently();
      if (!mounted) return;
      currentUserId = auth.currentUserId;
      ref.read(accountStatusProvider.notifier).refresh();
      final photoUrl = auth.currentPhotoUrl;
      final currentPrefs = ref.read(preferencesProvider).value;
      if (!auth.isAnonymous &&
          photoUrl != null &&
          photoUrl.isNotEmpty &&
          currentPrefs != null &&
          currentPrefs.googlePhotoUrl != photoUrl) {
        unawaited(
          ref
              .read(shoppingRepositoryProvider)
              .updatePreferences(
                googlePhotoUrl: photoUrl,
                avatarChoice: currentPrefs.avatarChoice == 'avatar_1'
                    ? 'google'
                    : null,
              ),
        );
      }
    } catch (e) {
      debugPrint('Karrito silent auth bootstrap skipped: $e');
    }

    if (!mounted) return;
    try {
      await ref
          .read(subscriptionServiceProvider)
          .configure(appUserId: currentUserId);
    } catch (e) {
      debugPrint('Karrito RevenueCat deferred configure skipped: $e');
    }

    if (!mounted) return;
    try {
      await ref
          .read(shoppingControllerProvider.notifier)
          .reprocessPendingAi(userTriggered: false);
    } catch (e) {
      debugPrint('Karrito pending AI reprocess skipped: $e');
    }

    if (!mounted) return;
    try {
      await ref
          .read(shoppingControllerProvider.notifier)
          .syncNow(userTriggered: false);
    } catch (e) {
      debugPrint('Karrito startup syncNow skipped: $e');
    }

    if (!mounted) return;
    try {
      await ref.read(shoppingControllerProvider.notifier).refreshPlanAndAds();
    } catch (e) {
      debugPrint('Karrito refreshPlanAndAds skipped: $e');
    }

    if (!mounted) return;
    try {
      if (ref.read(effectivePlanTierProvider) == KarritoPlanTier.free) {
        unawaited(
          ref.read(adsCascadeServiceProvider).preloadAdMobInterstitial(),
        );
      }
    } catch (e) {
      debugPrint('Karrito AdMob interstitial preload skipped: $e');
    }

    if (!mounted) return;
    try {
      _updateRealtimeSubscription(
        isOnline: ref.read(isOnlineProvider),
        activeList: ref.read(activeListProvider),
      );
    } catch (e) {
      debugPrint('Karrito realtime subscription skipped: $e');
    }
  }

  void _updateRealtimeSubscription({
    required bool isOnline,
    required ShoppingListEntity? activeList,
  }) {
    final targetId = (isOnline && activeList != null && activeList.isShared)
        ? activeList.id
        : null;

    if (targetId == _realtimeListId) {
      return;
    }

    final sync = ref.read(syncServiceProvider);
    final oldChannel = _realtimeChannel;
    _realtimeChannel = null;
    _realtimeListId = targetId;

    if (oldChannel != null) {
      unawaited(sync.unsubscribeChannel(oldChannel));
    }

    if (targetId != null) {
      _realtimeChannel = sync.subscribeToSharedList(targetId);
    }
  }

  ThemeMode _resolveThemeMode(String? rawMode) {
    switch (rawMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  KarritoToastType _resolveToastType(ShoppingUiState state) {
    if (state.isError) return KarritoToastType.error;
    final msg = state.feedbackMessage ?? '';
    if (msg == AppStrings.savedOfflineNotice ||
        msg == AppStrings.wakelockEnabledNotice ||
        msg == AppStrings.wakelockDisabledNotice ||
        msg == AppStrings.googleLinkedSyncPendingNotice ||
        msg == AppStrings.signedOutNotice ||
        msg == AppStrings.accountDeletedNotice) {
      return KarritoToastType.info;
    }
    return KarritoToastType.success;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ShoppingUiState>(shoppingControllerProvider, (previous, next) {
      if (next.messageVersion != previous?.messageVersion &&
          next.feedbackMessage != null &&
          mounted) {
        final overlay = _navigatorKey.currentState?.overlay;
        if (overlay != null) {
          KarritoToast.showInOverlay(
            overlay,
            message: next.feedbackMessage!,
            type: _resolveToastType(next),
          );
        }
      }
    });

    ref.listen<bool>(isOnlineProvider, (_, next) {
      _handleOnlineState(next);
      _updateRealtimeSubscription(
        isOnline: next,
        activeList: ref.read(activeListProvider),
      );
    });

    ref.listen<ShoppingListEntity?>(activeListProvider, (_, next) {
      _updateRealtimeSubscription(
        isOnline: ref.read(isOnlineProvider),
        activeList: next,
      );
    });

    ref.listen<AsyncValue<UserPreferencesEntity>>(preferencesProvider, (
      _,
      next,
    ) {
      final keepOn = next.value?.keepScreenOn;
      if (keepOn != null && keepOn != _lastKeepScreenOn) {
        _lastKeepScreenOn = keepOn;
        unawaited(ref.read(wakelockServiceProvider).setEnabled(keepOn));
      }
    });

    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.value;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _resolveThemeMode(prefs?.themeMode),
      themeAnimationDuration: const Duration(milliseconds: 280),
      themeAnimationCurve: Curves.easeInOutCubic,
      locale: const Locale('es', 'AR'),
      supportedLocales: const <Locale>[Locale('es', 'AR'), Locale('es')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: prefs == null
          ? const _StartupPlaceholder()
          : (prefs.onboardingCompleted
                ? const ShoppingListScreen()
                : const OnboardingScreen()),
    );
  }
}

class _StartupPlaceholder extends StatelessWidget {
  const _StartupPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

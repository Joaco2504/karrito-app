import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'providers/core_providers.dart';
import 'providers/shopping_providers.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/shopping_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
    postgrestOptions: const PostgrestClientOptions(
      schema: SupabaseConfig.schema,
    ),
  );

  runApp(const ProviderScope(child: KarritoApp()));
}

class KarritoApp extends ConsumerStatefulWidget {
  const KarritoApp({super.key});

  @override
  ConsumerState<KarritoApp> createState() => _KarritoAppState();
}

class _KarritoAppState extends ConsumerState<KarritoApp> {
  bool? _lastOnline;
  bool? _lastKeepScreenOn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleOnlineState(ref.read(isOnlineProvider));
    });
  }

  void _handleOnlineState(bool isOnline) {
    final wasOnline = _lastOnline;
    _lastOnline = isOnline;
    if (!isOnline) return;

    if (wasOnline != true) {
      unawaited(ref.read(authServiceProvider).ensureSignedInSilently());
      unawaited(
        ref
            .read(shoppingControllerProvider.notifier)
            .reprocessPendingAi(userTriggered: false),
      );
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

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isOnlineProvider, (_, next) {
      _handleOnlineState(next);
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
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _resolveThemeMode(prefs?.themeMode),
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

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../data/local/app_database.dart';
import '../data/repositories/shopping_repository.dart';
import '../data/services/ads_cascade_service.dart';
import '../data/services/ai_classifier_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/media_capture_service.dart';
import '../data/services/push_notification_service.dart';
import '../data/services/sound_service.dart';
import '../data/services/subscription_service.dart';
import '../data/services/sync_service.dart';
import '../data/services/wakelock_service.dart';

Future<bool>? _supabaseInitFuture;

Future<bool> ensureSupabaseInitializedSafely() {
  try {
    Supabase.instance.client;
    return Future<bool>.value(true);
  } catch (_) {
    // Not initialized yet.
  }

  return _supabaseInitFuture ??= () async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
        postgrestOptions: const PostgrestClientOptions(
          schema: SupabaseConfig.schema,
        ),
      ).timeout(const Duration(seconds: 8));
      return true;
    } catch (e) {
      debugPrint('Karrito Supabase deferred init skipped: $e');
      _supabaseInitFuture = null;
      return false;
    }
  }();
}

final supabaseInitializerProvider = Provider<Future<bool> Function()>((ref) {
  return ensureSupabaseInitializedSafely;
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final aiClassifierServiceProvider = Provider<AiClassifierService>((ref) {
  return SupabaseAiClassifierService(
    client: ref.watch(supabaseClientProvider),
    authService: ref.watch(authServiceProvider),
  );
});

final wakelockServiceProvider = Provider<WakelockService>((ref) {
  return PlatformWakelockService();
});

final soundFeedbackServiceProvider = Provider<SoundFeedbackService>((ref) {
  final service = AudioplayersSoundService();
  ref.onDispose(service.dispose);
  return service;
});

final adsCascadeServiceProvider = Provider<AdsCascadeService>((ref) {
  final service = SupabaseAdsCascadeService(
    db: ref.watch(appDatabaseProvider),
    client: ref.watch(supabaseClientProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return RevenueCatSubscriptionService();
});

final mediaCaptureServiceProvider = Provider<MediaCaptureService>((ref) {
  final service = KarritoMediaCaptureService();
  ref.onDispose(service.dispose);
  return service;
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = FirebasePushNotificationService(
    ref.watch(supabaseClientProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(
    db: ref.watch(appDatabaseProvider),
    aiClassifier: ref.watch(aiClassifierServiceProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SupabaseSyncService(
    db: ref.watch(appDatabaseProvider),
    client: ref.watch(supabaseClientProvider),
    authService: ref.watch(authServiceProvider),
  );
});

bool _hasConnectivity(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

final onlineStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  try {
    final initial = await connectivity.checkConnectivity();
    yield _hasConnectivity(initial);
  } catch (_) {
    yield false;
  }

  await for (final results in connectivity.onConnectivityChanged) {
    yield _hasConnectivity(results);
  }
});

/// Overridable boolean connectivity state used across repositories & UI.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(onlineStreamProvider).value ?? true;
});

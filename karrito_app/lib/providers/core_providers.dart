import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/app_database.dart';
import '../data/repositories/shopping_repository.dart';
import '../data/services/ai_classifier_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/sound_service.dart';
import '../data/services/sync_service.dart';
import '../data/services/wakelock_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
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
  ref.onDispose(() {
    service.dispose();
  });
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

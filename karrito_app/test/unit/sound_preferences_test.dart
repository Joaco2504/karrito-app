import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/constants/store_hierarchy.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/repositories/shopping_repository.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/data/services/sound_service.dart';
import 'package:karrito_app/data/services/sync_service.dart';
import 'package:karrito_app/providers/core_providers.dart';
import 'package:karrito_app/providers/shopping_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _NoopAiClassifier implements AiClassifierService {
  @override
  Future<ProcesarListaResponse> classifyText(String text) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }

  @override
  Future<ProcesarListaResponse> classifyAudio({
    required String audioBase64,
    String mimeType = 'audio/m4a',
  }) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }

  @override
  Future<ProcesarListaResponse> classifyImage({
    required String imageBase64,
    String mimeType = 'image/jpeg',
  }) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }
}

class _NoopSyncService implements SyncService {
  @override
  Future<void> syncAll() async {}

  @override
  Future<void> refreshAccountPlanAndConfig() async {}

  @override
  Future<LiveShareOutcome> enableLiveShare(ShoppingListEntity list) async {
    return const LiveShareOutcome.requiresPro();
  }

  @override
  Future<JoinedListResult> joinSharedListByCode(String rawCode) {
    throw UnimplementedError();
  }

  @override
  RealtimeChannel? subscribeToSharedList(String listId) => null;

  @override
  Future<void> unsubscribeChannel(RealtimeChannel? channel) async {}
}

class _RecordingSoundService implements SoundFeedbackService {
  final List<({bool playSound, bool triggerVibration})> calls =
      <({bool playSound, bool triggerVibration})>[];

  @override
  Future<void> playItemCheckedFeedback({
    bool playSound = true,
    bool triggerVibration = true,
  }) async {
    calls.add((playSound: playSound, triggerVibration: triggerVibration));
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test(
    'Drift schemaVersion 6 defaults sound, vibration, plan, and avatarChoice and persists updates',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(db.schemaVersion, 6);

      final repo = ShoppingRepository(
        db: db,
        aiClassifier: _NoopAiClassifier(),
      );

      final initial = await repo.watchPreferences().first;
      expect(initial.soundEnabled, isTrue);
      expect(initial.vibrationEnabled, isTrue);
      expect(initial.avatarChoice, 'avatar_1');
      expect(initial.googlePhotoUrl, isNull);

      await repo.updatePreferences(
        soundEnabled: false,
        vibrationEnabled: false,
        avatarChoice: 'avatar_4',
        googlePhotoUrl: 'https://example.com/photo.jpg',
      );
      final updated = await repo.watchPreferences().first;
      expect(updated.soundEnabled, isFalse);
      expect(updated.vibrationEnabled, isFalse);
      expect(updated.avatarChoice, 'avatar_4');
      expect(updated.googlePhotoUrl, 'https://example.com/photo.jpg');

      await repo.updatePreferences(
        soundEnabled: true,
        vibrationEnabled: true,
        clearGooglePhotoUrl: true,
        avatarChoice: 'avatar_1',
      );
      final restored = await repo.watchPreferences().first;
      expect(restored.soundEnabled, isTrue);
      expect(restored.vibrationEnabled, isTrue);
      expect(restored.googlePhotoUrl, isNull);
      expect(restored.avatarChoice, 'avatar_1');
    },
  );

  test(
    'Drift migration from schemaVersion 4 to 5 preserves data, adds v5 columns, and seeds new stores',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('karrito_v4_mig_');
      final dbFile = File('${tempDir.path}${Platform.pathSeparator}test.db');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      // Build a realistic schemaVersion 4 database via NativeDatabase setup hook,
      // then let Drift run its real onUpgrade(from: 4, to: 5) migration.
      final db = AppDatabase(
        NativeDatabase(
          dbFile,
          setup: (raw) {
            if (raw.userVersion != 0) return;
            raw.execute('''
              CREATE TABLE local_lists (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                owner_id TEXT,
                is_shared INTEGER NOT NULL DEFAULT 0,
                share_code TEXT,
                is_joined_remote INTEGER NOT NULL DEFAULT 0,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              );
            ''');
            raw.execute('''
              CREATE TABLE local_items (
                id TEXT NOT NULL PRIMARY KEY,
                list_id TEXT NOT NULL REFERENCES local_lists(id) ON DELETE CASCADE,
                raw_text TEXT NOT NULL,
                clean_name TEXT NOT NULL,
                quantity REAL NOT NULL DEFAULT 1.0,
                unit TEXT NOT NULL DEFAULT 'u',
                store_category TEXT NOT NULL,
                aisle_name TEXT NOT NULL,
                is_checked INTEGER NOT NULL DEFAULT 0,
                position INTEGER NOT NULL DEFAULT 0,
                updated_at INTEGER NOT NULL,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              );
            ''');
            raw.execute('''
              CREATE TABLE local_aisle_order (
                store_category TEXT NOT NULL,
                aisle_name TEXT NOT NULL,
                sort_order INTEGER NOT NULL,
                updated_at INTEGER,
                sync_status TEXT NOT NULL DEFAULT 'seeded',
                PRIMARY KEY (store_category, aisle_name)
              );
            ''');
            raw.execute('''
              CREATE TABLE local_learned_items (
                normalized_name TEXT NOT NULL PRIMARY KEY,
                display_name TEXT,
                preferred_store TEXT NOT NULL,
                preferred_aisle TEXT NOT NULL,
                use_count INTEGER NOT NULL DEFAULT 1,
                updated_at INTEGER NOT NULL,
                sync_status TEXT NOT NULL DEFAULT 'pending'
              );
            ''');
            raw.execute('''
              CREATE TABLE local_preferences (
                id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
                city TEXT NOT NULL DEFAULT 'Andalgalá',
                theme_mode TEXT NOT NULL DEFAULT 'system',
                onboarding_completed INTEGER NOT NULL DEFAULT 0,
                keep_screen_on INTEGER NOT NULL DEFAULT 1,
                sound_enabled INTEGER NOT NULL DEFAULT 1,
                last_synced_at INTEGER
              );
            ''');
            raw.execute('''
              CREATE TABLE local_pending_deletions (
                id TEXT NOT NULL PRIMARY KEY,
                entity_type TEXT NOT NULL,
                entity_key TEXT NOT NULL,
                is_leave_only INTEGER NOT NULL DEFAULT 0,
                deleted_at INTEGER NOT NULL
              );
            ''');
            raw.execute(
              'INSERT INTO local_preferences (id, city, theme_mode, onboarding_completed, keep_screen_on, sound_enabled) '
              "VALUES (1, 'Belén', 'dark', 1, 0, 0);",
            );
            raw.execute(
              'INSERT INTO local_aisle_order (store_category, aisle_name, sort_order, sync_status) '
              "VALUES ('Supermercado', 'Bebidas', 5, 'synced');",
            );
            raw.execute('PRAGMA user_version = 4;');
          },
        ),
      );
      addTearDown(db.close);

      final repo = ShoppingRepository(
        db: db,
        aiClassifier: _NoopAiClassifier(),
      );

      final prefs = await repo.watchPreferences().first;
      expect(prefs.city, 'Belén');
      expect(prefs.themeMode, 'dark');
      expect(prefs.onboardingCompleted, isTrue);
      expect(prefs.keepScreenOn, isFalse);
      expect(prefs.soundEnabled, isFalse);
      expect(prefs.vibrationEnabled, isTrue);
      expect(prefs.avatarChoice, 'avatar_1');
      expect(prefs.googlePhotoUrl, isNull);

      final aisleOrder = await repo.getAisleOrderMap();
      // Existing customized aisle order preserved.
      expect(aisleOrder[('Supermercado', 'Bebidas')], 5);
      // Newly introduced Phase 3.5 rubros seeded automatically.
      expect(aisleOrder[('Bazar y Hogar', 'Termos y Mate')], isNotNull);
      expect(
        aisleOrder[('Indumentaria y Calzado', 'Ropa Cotidiana')],
        isNotNull,
      );
      expect(
        aisleOrder[('Juguetería y Regalería', 'Juegos de Mesa')],
        isNotNull,
      );
      expect(
        aisleOrder[('Mascotas y Veterinaria', 'Alimento Balanceado')],
        isNotNull,
      );
      expect(
        aisleOrder[('Electrónica y Celulares', 'Cargadores y Cables')],
        isNotNull,
      );
      expect(
        aisleOrder[(
          StoreHierarchy.fallbackStore,
          StoreHierarchy.offlinePendingAisle,
        )],
        999,
      );
    },
  );

  test(
    'ShoppingController respects soundEnabled and vibrationEnabled independently on check',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final sound = _RecordingSoundService();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          aiClassifierServiceProvider.overrideWithValue(_NoopAiClassifier()),
          syncServiceProvider.overrideWithValue(_NoopSyncService()),
          soundFeedbackServiceProvider.overrideWithValue(sound),
          isOnlineProvider.overrideWithValue(false),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final prefsSub = container.listen(preferencesProvider, (_, _) {});
      addTearDown(prefsSub.close);
      await container.read(preferencesProvider.future);
      final lists = await db.select(db.localLists).get();
      final listId = lists.first.id;
      final now = DateTime.now();

      final item = ShoppingItemEntity(
        id: 'sound-test-item',
        listId: listId,
        rawText: 'Yerba',
        cleanName: 'Yerba',
        quantity: 1,
        unit: 'kg',
        storeCategory: 'Supermercado',
        aisleName: 'Almacén',
        isChecked: false,
        position: 0,
        updatedAt: now,
        syncStatus: 'pending',
      );
      await db.into(db.localItems).insert(item);

      final controller = container.read(shoppingControllerProvider.notifier);

      // 1. Both enabled -> sound + vibration triggered.
      await controller.toggleItemChecked(item);
      expect(sound.calls, hasLength(1));
      expect(sound.calls.last.playSound, isTrue);
      expect(sound.calls.last.triggerVibration, isTrue);

      // 2. Unchecking stays silent & non-vibrating.
      await controller.toggleItemChecked(item.copyWith(isChecked: true));
      expect(sound.calls, hasLength(1));

      // 3. Disable sound only -> still vibrates.
      await controller.setSoundEnabled(false);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await controller.toggleItemChecked(item);
      expect(sound.calls, hasLength(2));
      expect(sound.calls.last.playSound, isFalse);
      expect(sound.calls.last.triggerVibration, isTrue);

      // 4. Disable vibration too -> suppressed completely.
      await controller.setVibrationEnabled(false);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await controller.toggleItemChecked(item);
      expect(sound.calls, hasLength(2));

      // 5. Re-enable sound only -> plays sound without vibration.
      await controller.setSoundEnabled(true);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await controller.toggleItemChecked(item);
      expect(sound.calls, hasLength(3));
      expect(sound.calls.last.playSound, isTrue);
      expect(sound.calls.last.triggerVibration, isFalse);
    },
  );
}

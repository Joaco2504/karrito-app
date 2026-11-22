import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
}

class _NoopSyncService implements SyncService {
  @override
  Future<void> syncAll() async {}

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
  int playCount = 0;

  @override
  Future<void> playItemCheckedFeedback() async {
    playCount++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test(
    'Drift schemaVersion 4 defaults soundEnabled to true and persists updates',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(db.schemaVersion, 4);

      final repo = ShoppingRepository(
        db: db,
        aiClassifier: _NoopAiClassifier(),
      );

      final initial = await repo.watchPreferences().first;
      expect(initial.soundEnabled, isTrue);

      await repo.updatePreferences(soundEnabled: false);
      final updated = await repo.watchPreferences().first;
      expect(updated.soundEnabled, isFalse);

      await repo.updatePreferences(soundEnabled: true);
      final restored = await repo.watchPreferences().first;
      expect(restored.soundEnabled, isTrue);
    },
  );

  test(
    'ShoppingController plays check sound only when checking and soundEnabled is true',
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

      // Keep preferencesProvider subscribed while the test runs.
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

      // 1. Checking item with soundEnabled=true triggers sound.
      await controller.toggleItemChecked(item);
      expect(sound.playCount, 1);

      // 2. Unchecking item does NOT trigger sound.
      final checkedItem = item.copyWith(isChecked: true);
      await controller.toggleItemChecked(checkedItem);
      expect(sound.playCount, 1);

      // 3. Disabling soundEnabled suppresses sound even when checking.
      await controller.setSoundEnabled(false);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await controller.toggleItemChecked(item);
      expect(sound.playCount, 1);
    },
  );
}
